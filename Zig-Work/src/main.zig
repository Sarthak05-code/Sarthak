const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    var Names: std.ArrayList([]const u8) = .empty;
    defer Names.deinit(allocator);

    try Names.append(allocator, "Sarthak");
    try Names.append(allocator, "Ayush");
    try Names.append(allocator, "Rhythmn");
    try Names.append(allocator, "Thyrem");

    for (Names.items, 0..) |name, i| {
        std.debug.print("Name {d}: {s} \n", .{ i + 1, name });
    }
}
