const std = @import("std");

pub fn return_exp(x: u32, exp_level: u5) u32 {
    return x >> exp_level;
}

pub fn main() void {
    const array: [9]u32 = .{ 5, 2, 55, 1, 4, 2, 5, 2, 45 };

    for (0..array.len) |i| {
        const number = return_exp(array[i], 2);
        std.debug.print("The number {} is: {}\n", .{ array[i], number });
    }
}
