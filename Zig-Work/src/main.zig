const std = @import("std");
const lib = @import("Library.zig");

pub fn main(init: std.process.Init) !void {
    var cons: lib.Console = undefined;
    cons.init(init.io);

    if (try cons.ask("Enter a sentence: ")) |message| {
        if (lib.equals("Gojo Satorou", message)) {
            try cons.sayColored(lib.ColorAscii.yellow, "Domain Expansion: Are you {s} because you're the strongest, or are you the strongest because you're {s}?\n", .{ message, message });
        } else {
            try cons.sayColored(lib.ColorAscii.green, "You typed: {s}\n", .{message});
        }
    } else {
        try cons.sayColored(lib.ColorAscii.red, "Error: No input received. EOF reached!\n", .{});
    }
}
