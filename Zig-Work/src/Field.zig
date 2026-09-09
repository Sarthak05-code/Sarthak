const std = @import("std");
const Field = @import("main.zig");

const Tailor = struct {
    pub const InsideTailor = struct {
        pub const InsideAnotherTailor = struct {
            fn print() void {
                std.debug.print("Caller of the night", .{});
            }
        };
    };
};

pub fn main(init: std.process.Init) !void {
    _ = init;

    var outer: Field.Outer = .{};

    var tester: Field.Outer.Inner = .{
        .outer = &outer,
    };
    std.debug.print("Tester value {d} before init. \n", .{try tester.returnValue()});

    tester.init(12, .Large);

    std.debug.print("Tester value {d}. \n", .{try tester.returnValue()});
}
