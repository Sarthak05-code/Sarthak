const std = @import("std");
const L = @import("Library.zig");
pub fn main(init: std.process.Init) !void {
    var con: L.Console = undefined;
    con.init(init.io);

    const name = try con.ask("Enter your name : ") orelse return;
    try con.say("Hello, {s}", .{name});
}
