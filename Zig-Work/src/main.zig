const std = @import("std");

const ArrayList = std.ArrayList;

pub fn main(init: std.process.Init) !void {
    _ = init;

    const page_allocator = std.heap.page_allocator;

    // Directly using page_allocator
    var list: ArrayList(u8) = .empty;
    defer list.deinit(page_allocator);

    try list.append(page_allocator, 'H');
    try list.append(page_allocator, 'i');

    std.debug.print(
        "The value in the list is: {s}\n",
        .{list.items},
    );

    // Arena uses page_allocator underneath
    var arena = std.heap.ArenaAllocator.init(page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var lists: ArrayList(i32) = .empty;

    try lists.append(allocator, 12);
    try lists.append(allocator, 13);
    try lists.append(allocator, 14);

    std.debug.print(
        "The values in the array are: {any}\n",
        .{lists.items},
    );
}
