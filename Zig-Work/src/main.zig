const std = @import("std");
const lib = @import("Library.zig");

const ListItems = union(enum) {
    int: i64,
    text: []const u8,
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    var cons: lib.Console = undefined;
    cons.init(init.io);

    var mixed_list: std.ArrayList(ListItems) = .empty;
    defer mixed_list.deinit(allocator);

    try cons.sayColored(lib.ColorAscii.blue, "Mixed List => Accepts both i64 and []const u8 : \n", .{});
    try cons.say("Type number or text. Type done or enter to exit the loop.\n", .{});

    while (true) {
        const input_text = try cons.ask("Add items : ");

        if (input_text) |input| {
            if (input.len == 0 or lib.equals("done", input)) {
                break;
            }

            if (std.fmt.parseInt(i64, input, 10)) |num| {
                try mixed_list.append(allocator, .{ .int = num });
                try cons.sayColored(lib.ColorAscii.green, " --> Added items (Integer) : [{d}]\n", .{num});
            } else |_| {
                const owned_text = try allocator.dupe(u8, input);
                try mixed_list.append(allocator, .{ .text = owned_text });
                try cons.sayColored(lib.ColorAscii.green, " --> Added items (text) [{s}]\n", .{owned_text});
            }
        } else {
            break;
        }
    }
    try cons.sayColored(lib.ColorAscii.red, "Final array list values. \n", .{});
    if (mixed_list.items.len == 0) {
        try cons.say("Your arraylist is empty. \n", .{});
    } else {
        for (mixed_list.items, 1..) |items, i| {
            switch (items) {
                .int => |val| try cons.say("[{d}]. Items Name : {d}\n", .{ i, val }),
                .text => |val| try cons.say("[{d}]. Items Name : {s}\n", .{ i, val }),
            }
        }
    }
}
