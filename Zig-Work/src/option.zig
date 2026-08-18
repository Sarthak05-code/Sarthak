const std = @import("std");

pub fn return_exp_left(x: u32, exp_level: u5) u32 {
    return x >> exp_level;
}

// seems global variable are possible in zig, very nice.
const CONSTANT = 2;

pub fn return_exp_right(x: u32, exp_level: u5) u32 {
    return x << exp_level;
}

pub fn string_mover(allocator: std.mem.Allocator, string: []const u8, shift: usize) ![]u8 {
    const len = string.len;
    if (len == 0) return try allocator.dupe(u8, string);

    // Normalize shift if shift > string length
    const effective_shift = shift % len;
    if (effective_shift == 0) return try allocator.dupe(u8, string);

    // Allocate memory for the new shifted string
    const result = try allocator.alloc(u8, len);

    // Split index for right rotation
    const split = len - effective_shift;

    // Copy suffix to the beginning, then prefix to the end
    @memcpy(result[0..effective_shift], string[split..]);
    @memcpy(result[effective_shift..], string[0..split]);

    return result;
}

pub fn main() !void {
    const array: [9]u32 = .{ 5, 2, 55, 1, 4, 2, 5, 2, 45 };
    const name = "Sarthak";
    const allocator = std.heap.page_allocator;

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

    const result = try string_mover(allocator, name, 2);
    defer allocator.free(result);

    std.debug.print("Original : {s} | Shifted : {s}", .{ name, result });
}
