const std = @import("std");


pub fn main(init: std.process.Init) !void {
    _ = init;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(allocator);

    try list.append(allocator, 21);
    try list.append(allocator, 212);
    try list.append(allocator, 2121);
    try list.append(allocator, 212121);

    var names: std.ArrayList(u8) = .empty;
    defer names.deinit(allocator);
    try names.appendSlice(allocator, "Sarthak");
    try names.appendSlice(allocator, " Thapa");
    try names.appendSlice(allocator, " is");
    try names.appendSlice(allocator, " my name.");

    std.debug.print("The values are : {any}\n", .{list.items});
    std.debug.print("The string values are : {s}\n", .{names.items});
}
