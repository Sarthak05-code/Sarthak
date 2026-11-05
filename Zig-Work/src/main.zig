const std = @import("std");
const lib = @import("Library.zig");

// Helper: reads a line and converts it into an integer.
fn readInt(cons: *lib.Console, prompt: []const u8) !i32 {
    const input = (try cons.ask(prompt)) orelse return error.EndOfInput;
    return try std.fmt.parseInt(i32, input, 10);
}

pub fn main(init: std.process.Init) !void {
    var cons: lib.Console = undefined;
    cons.init(init.io);

    const allocator = init.arena.allocator();

    // 1. Get dimensions
    try cons.sayStyled(
        lib.ColorAscii.blue ++ lib.TextStyle.all_style,
        "Enter P (number of processes):\n",
        .{},
    );

    const p_input = try readInt(&cons, "> ");

    if (p_input <= 0) return error.InvalidProcessCount;

    const p: usize = @intCast(p_input);

    try cons.sayStyled(
        lib.ColorAscii.blue ++ lib.TextStyle.all_style,
        "Enter R (number of resources):\n",
        .{},
    );

    const r_input = try readInt(&cons, "> ");

    if (r_input <= 0) return error.InvalidResourceCount;

    const r: usize = @intCast(r_input);

    // 2. Allocate memory for matrices and vectors

    if (r > std.math.maxInt(usize) / p) {
        return error.DimensionOverflow;
    }

    const total = p * r;

    const alloc = try allocator.alloc(i32, total);
    const req = try allocator.alloc(i32, total);

    const avail = try allocator.alloc(i32, r);
    const worker = try allocator.alloc(i32, r);
    const finish = try allocator.alloc(bool, p);

    @memset(finish, false);

    // 3. Input Allocation matrix

    for (0..p) |i| {
        for (0..r) |j| {
            try cons.sayStyled(
                lib.TextStyle.bold_italic ++ lib.ColorAscii.yellow,
                "Enter Alloc[{d}][{d}]:\n",
                .{ i, j },
            );

            const value = try readInt(&cons, "> ");

            if (value < 0) return error.NegativeResourceValue;

            alloc[i * r + j] = value;
        }
    }

    // 4. Input Request matrix

    for (0..p) |i| {
        for (0..r) |j| {
            try cons.sayStyled(
                lib.TextStyle.bold_italic ++ lib.ColorAscii.green,
                "Enter Request[{d}][{d}]:\n",
                .{ i, j },
            );

            const value = try readInt(&cons, "> ");

            if (value < 0) return error.NegativeResourceValue;

            req[i * r + j] = value;
        }
    }

    // 5. Input Available vector

    for (0..r) |j| {
        try cons.sayStyled(
            lib.ColorAscii.cyan ++ lib.ColorAscii.bold,
            "Enter Available[{d}]:\n",
            .{j},
        );

        const value = try readInt(&cons, "> ");

        if (value < 0) return error.NegativeResourceValue;

        avail[j] = value;
    }

    // 6. Initialize Work = Available

    @memcpy(worker, avail);

    // 7. Mark processes holding no resources as finished

    for (0..p) |i| {
        var holding_resources = false;

        for (0..r) |j| {
            if (alloc[i * r + j] != 0) {
                holding_resources = true;
                break;
            }
        }

        if (!holding_resources) {
            finish[i] = true;
        }
    }

    // 8. Deadlock Detection Algorithm

    var found = true;

    while (found) {
        found = false;

        for (0..p) |i| {
            if (!finish[i]) {
                var can_finish = true;

                // Check Request <= Work

                for (0..r) |j| {
                    if (req[i * r + j] > worker[j]) {
                        can_finish = false;
                        break;
                    }
                }

                // Release resources if process can finish

                if (can_finish) {
                    for (0..r) |j| {
                        worker[j] += alloc[i * r + j];
                    }

                    finish[i] = true;
                    found = true;
                }
            }
        }
    }

    // 9. Identify deadlocked processes

    var deadlock = false;

    std.debug.print("\nDeadlocked processes: ", .{});

    for (0..p) |i| {
        if (!finish[i]) {
            std.debug.print("P{d} ", .{i});
            deadlock = true;
        }
    }

    if (deadlock) {
        std.debug.print("\nSYSTEM IS IN DEADLOCK.\n", .{});
    } else {
        std.debug.print("None\nSYSTEM IS NOT IN DEADLOCK.\n", .{});
    }
}
