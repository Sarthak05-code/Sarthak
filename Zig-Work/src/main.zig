const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(allocator);

    try list.append(allocator, 12);
    try list.append(allocator, 13);
    try list.append(allocator, 14);
    try list.append(allocator, 15);
    try list.append(allocator, 16);

    for (1.., list.items) |i, item| {
        if (@mod(item, 2) == 0) {
            std.debug.print("{d}. The item : {d} is even. \n", .{ i, item });
        } else {
            std.debug.print("{}. The item : {d} is odd. \n", .{ i, item });
        }
    }
}
