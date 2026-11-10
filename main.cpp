
#include <cstddef>
#include <iostream>
#include <queue>
#include <stack>
#include <vector>

using namespace std;

// Graph representation using adjacency lists
struct graph {
  vector<vector<size_t>> nodes;
};

// Retrieve the next element from a queue
template <typename T, typename C> T take_next(queue<T, C> &container) {
  T value = container.front();
  container.pop();
  return value;
}

// Retrieve the next element from a stack
template <typename T, typename C> T take_next(stack<T, C> &container) {
  T value = container.top();
  container.pop();
  return value;
}

// Generic graph traversal
template <template <typename...> typename Container>
bool cfs(const graph &g, size_t from, size_t to) {

  if (from >= g.nodes.size() || to >= g.nodes.size())
    return false;

  if (from == to)
    return true;

  vector<bool> visited(g.nodes.size(), false);

  Container<size_t> container{};

  container.push(from);
  visited[from] = true;

  while (!container.empty()) {

    const auto cur = take_next(container);

    for (const auto next : g.nodes[cur]) {

      if (next >= g.nodes.size() || visited[next])
        continue;

      if (next == to)
        return true;

      visited[next] = true;
      container.push(next);
    }
  }

  return false;
}

// BFS
const auto bfs = [](const graph &g, size_t from, size_t to) {
  return cfs<queue>(g, from, to);
};

// DFS
const auto dfs = [](const graph &g, size_t from, size_t to) {
  return cfs<stack>(g, from, to);
};

int main() {

  graph g;

  g.nodes = {
      {1, 2},    // 0
      {0, 3, 4}, // 1
      {0, 5, 6}, // 2
      {1},       // 3
      {1},       // 4
      {2},       // 5
      {2}        // 6
  };

  cout << "BFS: " << bfs(g, 0, 6) << endl;
  cout << "DFS: " << dfs(g, 0, 6) << endl;

  return 0;
}
