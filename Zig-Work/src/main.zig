const std = @import("std");
const lib = @import("Library.zig");

const ListItems = union(enum) {
    int: i64,
    text: []const u8,
    points: f64,
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();

    var cons: lib.Console = undefined;
    cons.init(init.io);

    var hetero_list: std.ArrayList(ListItems) = .empty;
    defer hetero_list.deinit(allocator);

    try cons.sayStyled(
        lib.ColorAscii.bold ++
            lib.ColorAscii.blue ++
            lib.ColorAscii.bg_yellow,
        "Mixed Array List.\n",
        .{},
    );

    try cons.say(
        "Enter an integer, double, or text. Press Enter or type done to exit.\n",
        .{},
    );

    while (true) {
        const input_text = try cons.ask("Add items: ");

        if (input_text) |input| {
            if (input.len == 0 or lib.equals("done", input)) {
                break;
            }

            const parsed_int: ?i64 =
                std.fmt.parseInt(i64, input, 10) catch null;

            if (parsed_int) |number| {
                try hetero_list.append(allocator, .{ .int = number });

                try cons.sayColored(
                    lib.ColorAscii.italic ++ lib.ColorAscii.bright_green,
                    " --> You entered (Integer): [{d}]\n",
                    .{number},
                );
            } else {
                const parsed_float: ?f64 =
                    std.fmt.parseFloat(f64, input) catch null;

                if (parsed_float) |number| {
                    try hetero_list.append(allocator, .{ .points = number });

                    try cons.sayColored(
                        lib.ColorAscii.italic ++ lib.ColorAscii.bright_green,
                        " --> You entered (Float): [{d}]\n",
                        .{number},
                    );
                } else {
                    const owned_text = try allocator.dupe(u8, input);

                    try hetero_list.append(
                        allocator,
                        .{ .text = owned_text },
                    );

                    try cons.sayColored(
                        lib.ColorAscii.italic ++ lib.ColorAscii.bright_green,
                        " --> You entered (String): [{s}]\n",
                        .{owned_text},
                    );
                }
            }
        } else {
            break;
        }
    }

    try cons.sayColored(lib.TextStyle.success, "Do you wanna see the final list.?\n", .{});
    try cons.sayColored(lib.TextStyle.highlighted ++ lib.TextStyle.success, "Yes -> \n", .{});
    try cons.sayColored(lib.TextStyle.highlighted ++ lib.TextStyle.error_msg, "No. -> \n", .{});
    const answer = try cons.ask(">. ");
    if (answer) |ans| {
        if (lib.equalsIgnoreCase(ans, "Yes")) {
            for (hetero_list.items, 1..) |items, i| {
                switch (items) {
                    .int => |val| try cons.sayColored(lib.TextStyle.all_style ++ lib.ColorAscii.blue, "[{d}] Items (Integer): {d}\n", .{ i, val }),
                    .points => |val| try cons.sayColored(lib.TextStyle.all_style ++ lib.ColorAscii.purple, "[{d}] Items (float): {any}\n", .{ i, val }),
                    .text => |val| try cons.sayColored(lib.TextStyle.all_style ++ lib.ColorAscii.cyan, "[{d}] Items (string): {s}\n", .{ i, val }),
                }
            }
        } else {
            try cons.sayColored(lib.TextStyle.bold_underline ++ lib.ColorAscii.green, "Thank you. \n", .{});
        }
    } else {
        try cons.sayColored(lib.TextStyle.error_msg, "Error in Input.\n", .{});
    }
}
