const std = @import("std");
const lib = @import("Library.zig");

pub fn main() !void {
    var buf: [256]u8 = undefined;
    var w: std.Io.Writer = .fixed(&buf);

    try lib.csv.writeRow(&w, &.{ "id", "name" });
    try lib.csv.writeRow(&w, &.{ "1", "Sarthak, S." });

    std.debug.print("{s}", .{w.buffered()});

    lib.print("Hello, from the smaller printer\n", .{});

    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var root = try lib.Node.init(allocator, 10);
    root = try lib.Node.init(allocator, 120);
    root = try lib.Node.init(allocator, 110);
    root = try lib.Node.init(allocator, 130);
    root = try lib.Node.init(allocator, 150);

    std.debug.print("Post Order : ", .{});
    lib.postOrder(root);


    
}
