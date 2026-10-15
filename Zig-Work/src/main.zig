const std = @import("std");
const L = @import("Library.zig");
const assert = std.debug.assert;

const State = enum(u32) { LOW = 10, MEDIUM = 100, HIGH = 1000 };

// IMPORTANT : Main function to run the library.
pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    const message = try L.returnApiUsage(allocator, "Sarthak", "Paid");
    std.debug.print("Message : {s}\n", .{message});

    const number: ?i32 = null;
    std.debug.print("The output should be {any} : for {any}\n", .{ try ifElseTester(number), number });

    const state: State = .LOW;
    const answer = switch (state) {
        .LOW => "Lower",
        .MEDIUM => "Higher",
        .HIGH => "Highest",
    };

    std.debug.print("The Current State : {d} is : {s}\n", .{ @intFromEnum(state), answer });
}

pub fn ifElseTester(number: ?i32) !?i32 {
    if (number) |num| return num + 1 else return 0;
}
