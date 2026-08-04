const std = @import("std");

pub fn caller(x: i32) i32 {
    return x * 2;
}

pub fn name_concatenate(
    allocator: std.mem.Allocator,
    alpha: []const u8,
) ![]const u8 {
    return try std.mem.concat(allocator, u8, &[_][]const u8{
        alpha,
        "Thapa",
    });
}

pub fn main() !void {
    // Create an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    // Number example
    const value = caller(12);
    std.debug.print("The value of 12 is: {}\n", .{value});

    // Name concatenation example
    const name = "Sarthak";
    const full_name = try name_concatenate(allocator, name);

    // Free the allocated memory when done
    defer allocator.free(full_name);

    std.debug.print("The full name of {s} is {s}\n", .{ name, full_name });
}
