const std = @import("std");
const lib = @import("Library.zig");


pub fn main() !void {
    var buf: [256]u8 = undefined;
    var w: std.Io.Writer = .fixed(&buf);

    try lib.csv.writeRow(&w, &.{ "id", "name" });
    try lib.csv.writeRow(&w, &.{ "1", "Sarthak, S." });

    std.debug.print("{s}", .{w.buffered()});

    lib.print("Hello, from the smaller printer\n" , .{});
}
