const std = @import("std");
const built = @import("builtin");
const os = built.os.tag;

pub fn main() void {
    if (os == .windows) {
        std.debug.print("The os is windows. \n", .{});
    } else {
        std.debug.print("The os is known: \n", .{});
    }

    var i : i32 = 0;
    while (i < 10) : (i += 1) {
        std.debug.print("{}\n", .{i + 1});
    }
}
