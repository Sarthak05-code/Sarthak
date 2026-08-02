package main

import (
	"bytes"
	"context"
	"fmt"
	"os/exec"
	"sync"
	"time"
)

// ---- 1. CORE TYPES ----
type TaskState string

const (
	TaskPending   TaskState = "PENDING"
	TaskScheduled TaskState = "SCHEDULED"
	TaskRunning   TaskState = "RUNNING"
	TaskCompleted TaskState = "COMPLETED"
	TaskFailed    TaskState = "FAILED"
)

type Task struct {
	ID        string
	Command   string   // e.g. "echo"
	Args      []string // e.g. ["Hello", "World"]
	State     TaskState
	WorkerID  string
	Output    string
	ErrorMsg  string
	CreatedAt time.Time
}

type Worker struct {
	ID       string
	LastSeen time.Time
}

type EventType string

const (
	EventTaskCreated EventType = "TASK_CREATED"
	EventTaskUpdated EventType = "TASK_UPDATED"
)

type WatchEvent struct {
	Type EventType
	Task *Task
}

// ---- 2. API SERVER / STATE STORE ----
type APIServer struct {
	mu          sync.RWMutex
	tasks       map[string]*Task
	workers     map[string]*Worker
	subscribers []chan WatchEvent
}

func NewAPIServer() *APIServer {
	return &APIServer{
		tasks:   make(map[string]*Task),
		workers: make(map[string]*Worker),
	}
}

func (api *APIServer) Watch() <-chan WatchEvent {
	api.mu.Lock()
	defer api.mu.Unlock()

	ch := make(chan WatchEvent, 100)
	api.subscribers = append(api.subscribers, ch)
	return ch
}

func (api *APIServer) broadcast(event WatchEvent) {
	api.mu.RLock()
	defer api.mu.RUnlock()

	for _, sub := range api.subscribers {
		select {
		case sub <- event:
		default: // Non-blocking
		}
	}
}

func (api *APIServer) SubmitTask(id string, command string, args []string) {
	api.mu.Lock()
	task := &Task{
		ID:        id,
		Command:   command,
		Args:      args,
		State:     TaskPending,
		CreatedAt: time.Now(),
	}
	api.tasks[id] = task
	api.mu.Unlock()

	fmt.Printf("[API Server] Submitted Task %s: '%s %v'\n", id, command, args)
	api.broadcast(WatchEvent{Type: EventTaskCreated, Task: task})
}

func (api *APIServer) UpdateTaskState(id string, state TaskState, workerID string, output string, err string) {
	api.mu.Lock()
	task, exists := api.tasks[id]
	if !exists {
		api.mu.Unlock()
		return
	}

	task.State = state
	if workerID != "" {
		task.WorkerID = workerID
	}
	if output != "" {
		task.Output = output
	}
	if err != "" {
		task.ErrorMsg = err
	}
	api.mu.Unlock()

	api.broadcast(WatchEvent{Type: EventTaskUpdated, Task: task})
}

func (api *APIServer) Heartbeat(workerID string) {
	api.mu.Lock()
	defer api.mu.Unlock()
	api.workers[workerID] = &Worker{
		ID:       workerID,
		LastSeen: time.Now(),
	}
}

func (api *APIServer) GetHealthyWorkerIDs(timeout time.Duration) []string {
	api.mu.RLock()
	defer api.mu.RUnlock()

	var active []string
	now := time.Now()
	for id, w := range api.workers {
		if now.Sub(w.LastSeen) <= timeout {
			active = append(active, id)
		}
	}
	return active
}

// ---- 3. SCHEDULER ----
func StartScheduler(api *APIServer) {
	events := api.Watch()

	go func() {
		var roundRobin int
		for event := range events {
			task := event.Task

			// Schedule pending tasks
			if task.State == TaskPending {
				workers := api.GetHealthyWorkerIDs(3 * time.Second)
				if len(workers) == 0 {
					fmt.Printf("[Scheduler] Warning: No healthy workers available for task %s!\n", task.ID)
					continue
				}

				// Pick worker via Round-Robin
				assignedWorker := workers[roundRobin%len(workers)]
				roundRobin++

				fmt.Printf("[Scheduler] Assigned Task '%s' to Worker '%s'\n", task.ID, assignedWorker)
				api.UpdateTaskState(task.ID, TaskScheduled, assignedWorker, "", "")
			}
		}
	}()
}

// ---- 4. WORKER NODE (Executes Shell Commands) ----
type WorkerRunner struct {
	ID     string
	api    *APIServer
	stopCh chan struct{}
}

func NewWorkerRunner(id string, api *APIServer) *WorkerRunner {
	return &WorkerRunner{
		ID:     id,
		api:    api,
		stopCh: make(chan struct{}),
	}
}

func (w *WorkerRunner) Start() {
	// 1. Heartbeat Goroutine
	go func() {
		ticker := time.NewTicker(1 * time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-ticker.C:
				w.api.Heartbeat(w.ID)
			case <-w.stopCh:
				return
			}
		}
	}()

	// 2. Task Listener
	events := w.api.Watch()
	go func() {
		for event := range events {
			task := event.Task
			// Only pick up tasks scheduled specifically for this worker
			if task.State == TaskScheduled && task.WorkerID == w.ID {
				go w.executeTask(task)
			}
		}
	}()
}

func (w *WorkerRunner) executeTask(task *Task) {
	fmt.Printf("[%s Worker] Starting Task '%s'...\n", w.ID, task.ID)
	w.api.UpdateTaskState(task.ID, TaskRunning, w.ID, "", "")

	// Set a execution timeout guard
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, task.Command, task.Args...)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()

	if err != nil {
		fmt.Printf("[%s Worker] Task '%s' Failed: %v\n", w.ID, task.ID, err)
		w.api.UpdateTaskState(task.ID, TaskFailed, w.ID, stdout.String(), err.Error())
		return
	}

	fmt.Printf("[%s Worker] Task '%s' Completed Successfully!\n", w.ID, task.ID)
	w.api.UpdateTaskState(task.ID, TaskCompleted, w.ID, stdout.String(), "")
}

// ---- 5. RECOVERY MANAGER (Re-schedules Dead Tasks) ----
func StartHealthMonitor(api *APIServer) {
	go func() {
		ticker := time.NewTicker(2 * time.Second)
		defer ticker.Stop()

		for range ticker.C {
			healthy := api.GetHealthyWorkerIDs(3 * time.Second)
			healthyMap := make(map[string]bool)
			for _, id := range healthy {
				healthyMap[id] = true
			}

			api.mu.RLock()
			for _, task := range api.tasks {
				// If a task is scheduled or running on a dead worker, re-queue it!
				if (task.State == TaskScheduled || task.State == TaskRunning) && !healthyMap[task.WorkerID] {
					fmt.Printf("[HealthMonitor] Worker '%s' is DEAD! Rescheduling Task '%s'...\n", task.WorkerID, task.ID)
					go api.UpdateTaskState(task.ID, TaskPending, "", "", "Worker Node Died")
				}
			}
			api.mu.RUnlock()
		}
	}()
}

// ---- 6. DEMO / TEST RUNNER ----
func main() {
	api := NewAPIServer()

	// Start Scheduler and Failover Monitor
	StartScheduler(api)
	StartHealthMonitor(api)

	// Spawn 2 Active Worker Nodes
	worker1 := NewWorkerRunner("worker-alpha", api)
	worker2 := NewWorkerRunner("worker-beta", api)

	worker1.Start()
	worker2.Start()

	// Give workers a moment to heartbeat & register
	time.Sleep(500 * time.Millisecond)

	fmt.Println("\n--- Submitting Real Terminal Tasks ---")

	// Task 1: Print text
	api.SubmitTask("task-1", "echo", []string{"Hello from Real Task Scheduler!"})

	// Task 2: Simulate work with sleep
	api.SubmitTask("task-2", "sleep", []string{"1"})

	// Task 3: Command that will fail
	api.SubmitTask("task-3", "ls", []string{"/non_existent_directory_xyz"})

	time.Sleep(3 * time.Second)

	// Output summary
	fmt.Println("\n--- Final Task Reports ---")
	api.mu.RLock()
	for id, t := range api.tasks {
		fmt.Printf("[%s] State: %-10s | Output: %-35q | Err: %s\n",
			id, t.State, t.Output, t.ErrorMsg)
	}
	api.mu.RUnlock()
}
