const std = @import("std");

var isThere: ?bool = null;
var name : ?[]const u8 = "Sarthak";
var number : ?i32 = 55;
var array: [4]i32 = .{1,2,3,4};

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

    isThere = true;
    if (isThere.?)  {
        std.debug.print("Someone is there: \n", .{});
    } else {
        std.debug.print("No one is there. \n", .{});
    }

    if (name) |present| {
        std.debug.print("Hello {s}\n", .{present});
    } else {
        std.debug.print("Hello, Stranger.\n", .{});
    }

    if (number) |_| {
        std.debug.print("The number is {any}\n", .{number});
    } else {
        std.debug.print("No number. \n", .{});
    }

    std.debug.print("The numbers : {any}\n", .{array});
}
