const std = @import("std");
const library = @import("Library.zig");

const Status = enum(u32) {
    Clear = 200,
    Forbidden = 403,
    Error = 404,
};

// Made a Libray function to text stuffs as well as test zig 0.17.0
pub fn main(init: std.process.Init) !void {
    _ = init;
    const text = "    Sarthak Thapa     ";
    const answer = library.trim(text);
    std.debug.print("{s}\n", .{text});
    std.debug.print("{s}\n", .{answer});

    if (library.startsWith(text, "Sar")) {
        std.debug.print("Correct!\n", .{});
    } else {
        std.debug.print("Incorrect \n", .{});
    }

    library.println("Hello, world");

    const server_connection: bool = false;
    const admin: bool = false;

    if (server_connection and admin) {
        std.debug.print("Current connection : {s}\n", .{if (@backingInt(Status.Clear) == 200) "Stable"});
    } else if (server_connection and !admin) {
        std.debug.print("Current connection : {s}\n", .{if (@backingInt(Status.Forbidden) == 403) "Forbidden"});
    } else {
        std.debug.print("Current Connection : {s}\n", .{if (@backingInt(Status.Error) == 404) "Error."});
    }

    if (library.containsG(i32, &[_]i32{1,2,3,4,5,6}, &[_]i32{10,20})) {
        std.debug.print("Values do exists in the array\n", .{});
    } else {
        std.debug.print("They dont exist. \n", .{});
    }
}
