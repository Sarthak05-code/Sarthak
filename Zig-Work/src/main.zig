const std = @import("std");
const l = @import("Library.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    var list: std.ArrayList(u32) = .empty;

    const char: u8 = 'a';

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

    std.debug.print("{c}\n", .{char});

    const numbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const needle = 11;
    std.debug.print("Number -> {} in array : {any} was : {}\n", .{ needle, numbers, l.linearSearch(i32, &numbers, needle) });
    std.debug.print("Number -> {} in array : {any} was : {}\n", .{ needle, numbers,  l.binarySearch(&numbers, needle) });
}
