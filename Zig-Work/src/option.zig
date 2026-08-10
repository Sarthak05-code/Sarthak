const std = @import("std");


pub fn divisionTest(x: f64) ?f64 {
    if (x > -1) {
        return @mod(x, 0);
    }
    return null;
}

pub fn main() !void {
    const value = divisionTest(12);
    std.debug.print("The valye is {any}\n", .{value});
}
