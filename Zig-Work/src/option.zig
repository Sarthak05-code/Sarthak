const std = @import("std");

pub fn number_div(x: f64, y: f64) !f64 {
    return x / y;
}

test "Number Division" {
    const result = try number_div(12.0, 2.0);
    try std.testing.expectEqual(6.0, result);
}

pub fn main() !void {
    std.debug.print("Hello, world", .{});
}
