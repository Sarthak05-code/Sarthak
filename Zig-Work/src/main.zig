const std = @import("std");
const L = @import("Library.zig");
pub fn main(init: std.process.Init) !void {
    var con: L.Console = undefined;
    con.init(init.io);

    const Text = try con.ask("Enter any text : ") orelse return;

    if (L.equals(Text, "Hello")) {
        L.println("Hello to you too.");
    } else if (L.equals(Text, "Sarthak")) {
        L.println("Hello , creator ");
    } else {
        L.println("HUH?");
    }
}

const Status = enum(u32) { Ok = 200, Error = 404, Forbidden = 403 };
