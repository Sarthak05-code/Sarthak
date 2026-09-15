const std = @import("std");


const Scale = enum { Small, Medium, Large, ExtraLarge };

const Rectal = struct {};

pub fn main(init: std.process.Init) !void {
    _ = init;

    const number = 14;

    switch (number % 5) {
        1 => std.debug.print("The number is 1", .{}),
        2 => std.debug.print("The number is 2", .{}),
        else => std.debug.print("The number is weird. ", .{}),
    }
}
