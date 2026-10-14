const std = @import("std");
const L = @import("Library.zig");

// IMPORTANT : Main function to run the library.
pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    const message = try L.returnApiUsage(allocator, "Sarthak", "Paid");
    std.debug.print("Message : {s}\n", .{message});

    const number : ?i32 = null;
    std.debug.print("The output should be {any} : for {any}", .{ try ifElseTester(number), number });
}

pub fn ifElseTester(number: ?i32) !?i32 {
    if (number) |num| return num + 1  else return 0;
}
