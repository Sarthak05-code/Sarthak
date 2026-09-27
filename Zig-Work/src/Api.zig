const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    const contents = try std.Io.Dir.cwd().readFileAlloc(
        io,
        "hello.txt",
        arena,
        .limited(1024 * 1024),
    );

    std.debug.print("{s}\n", .{contents});
}