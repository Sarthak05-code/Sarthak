const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var buffer: [100]u8 = undefined;

    std.debug.print("Enter number of frames (1-5): ", .{});

    const stdin = std.Io.File.stdin();

    const len = try stdin.readStreaming(init.io, &.{&buffer});

    const input = buffer[0..len];
    const trimmed = std.mem.trim(u8, input, " \r\n");

    const number = try std.fmt.parseInt(usize, trimmed, 10);

    if (number < 1 or number > 5) {
        std.debug.print("Frames must be between 1 and 5.\n", .{});
        return;
    }

    const frames = try init.gpa.alloc(i64, number);
    defer init.gpa.free(frames);

    // Initially all frames are empty
    for (frames) |*frame| {
        frame.* = -1;
    }

    // Page reference string
    const pages = [_]i64{ 1, 2, 3, 4, 1, 2, 5 };

    var next: usize = 0;
    var page_faults: usize = 0;

    for (pages) |page| {
        var found = false;

        // Check whether page already exists
        for (frames) |frame| {
            if (frame == page) {
                found = true;
                break;
            }
        }

        if (!found) {
            // Page fault
            frames[next] = page;

            next = (next + 1) % number;

            page_faults += 1;
        }

        std.debug.print("Page {d}: {any} -> {s}\n", .{ page, frames, if (found) "hit" else "fault" });
    }

    std.debug.print("\nTotal page faults: {d}\n", .{page_faults});
}
