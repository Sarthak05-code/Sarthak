const std = @import("std");
const built = @import("builtin");

const os = built.os.tag;

const Tailor = struct {
    pub const InsideTailor = struct {
        pub const InsideAnotherTailor = struct {
            pub fn printer() void {
                std.debug.print("Caller of the night", .{});
            }
        };
    };
};

const Os = enum {
    Windows,
    Macos,
    Linux,
};

pub fn main(init: std.process.Init) !void {
    _ = init;
    Tailor.InsideTailor.InsideAnotherTailor.printer();
    std.debug.print("\nThe current os you are using is : {s}\n", .{if (os == .windows) "Window" else "Unknown"});
    const name = Os.Windows;
    std.debug.print("{}", .{name});
}
