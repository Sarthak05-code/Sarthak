const A = @import("option.zig");
const std = @import("std");
const built = @import("builtin");
const os = built.os.tag;
const hash = std.crypto.hash;

pub fn main() !void {
    var pos: A.Advance = .{};
    pos.advance();
    std.debug.print("Current pos : {} \n ", .{pos});

    switch (os) {
        .windows => {
            pos.reset();
            pos.scalable_advance(5);
            std.debug.print("Since your windows, you moved 5 steps ahead , Current pos : {}\n", .{pos});
        },
        .linux => {
            pos.reset();
            pos.scalable_advance(2);
            std.debug.print("Since your linux, you moved 2 steps, Current pos : {} \n", .{pos});
        },
        .macos => {
            pos.reset();
            pos.scalable_advance(10);
            std.debug.print("Since your Mac, you moved 10 steps, Current pos : {} \n", .{pos});
        },
        else => {
            std.debug.print("Unknown os , failed to proceed.\n", .{});
        },
    }
}
