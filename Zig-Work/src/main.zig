const std = @import("std");

pub fn main() !void {
    std.debug.print("This should work. \n", .{});
    std.debug.print("This\tname\twill\thave\tspace", .{});
}
