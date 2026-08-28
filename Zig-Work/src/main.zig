const std = @import("std");

const GLOBAL : i32 = 1;


pub const Outer = struct {
    pub const Inner = struct {
        value: i32 = undefined,
        is_active: bool = false,

        const InnerError = error{NotActive};

        pub fn init(self: *Inner) void {
            self.value = 0;
            self.is_active = true;
        }

        pub fn return_value(self: *const Inner) InnerError!i32 {
            if (!self.is_active) {
                return error.NotActive;
            }
            return self.value;
        }
    };
};

pub fn main() !void {
    std.debug.print("This should work. \n", .{});
    std.debug.print("This\tname\twill\thave\tspace", .{});

    var tester: Outer.Inner = .{};

    const before = tester.return_value() catch |err| blk: {
        std.debug.print("Not ready yet: {}\n", .{err});
        break :blk -1;
    };
    std.debug.print("Value is: {}\n", .{before});

    tester.init();

    const after = try tester.return_value();
    std.debug.print("Value is: {}\n", .{after});
}
