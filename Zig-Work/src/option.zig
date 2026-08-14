const std = @import("std");

pub fn return_exp_left(x: u32, exp_level: u5) u32 {
    return x >> exp_level;
}

// seems global variable are possible in zig, very nice.
const CONSTANT = 2;

pub fn return_exp_right(x: u32, exp_level: u5) u32 {
    return x << exp_level;
}

pub fn main() void {
    const array: [9]u32 = .{ 5, 2, 55, 1, 4, 2, 5, 2, 45 };

    for (0..array.len) |i| {
        // zig seems to not use a typical number % 2 == 0; so i am using the prefered @mod method.
        if (@mod(array[i], 2) == 0) {
            const number = return_exp_right(array[i], CONSTANT);
            std.debug.print("The number {} is {}\n", .{ array[i], number });
        } else {
            const number = return_exp_left(array[i], CONSTANT);
            std.debug.print("The number {} is {}\n", .{ array[i], number });
        }
    }
}
