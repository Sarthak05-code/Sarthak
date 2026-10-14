const std = @import("std");
const L = @import("Library.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    const message = try L.returnApiUsage(allocator, "Sarthak", "Paid");
    std.debug.print("Message : {s}", .{message});
}
