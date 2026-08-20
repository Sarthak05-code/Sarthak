const std = @import("std");

pub fn main() !void {
    const stdout = "Hello, world";
    std.debug.print("{s}", .{stdout});
}
