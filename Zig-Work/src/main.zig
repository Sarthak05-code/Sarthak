const std = @import("std");

pub fn caller(x: i32) !i32 {
    return x * 2;
}

pub fn main() !void {
    const value = try caller(12);
    std.debug.print("The value of 12 is : {}", .{value});
}
