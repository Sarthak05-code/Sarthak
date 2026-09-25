const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;
    _ = gpa;

    var group: std.Io.Group = .init;
    defer group.cancel(io);

    std.debug.print("Spawing parallel workers : [n", .{});
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        group.async(io, workerTask, .{ io, i });
    }

    std.debug.print("All task spawned. Waiting for the group completion...\n", .{});

    try group.await(io);
    std.debug.print("All works done.\n", .{});
}

fn workerTask(io: Io, id: usize) void {
    std.debug.print("Worker : {d} started\n", .{id});

    io.sleep(.fromSeconds(1), .awake) catch {};

    std.debug.print("Worker {d} finished.\n", .{id});
}
