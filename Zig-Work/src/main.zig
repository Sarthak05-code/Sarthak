const std = @import("std");

// * This is the main Struct
pub const Outer = struct {
    const Size = enum { Small, Medium, Large };

    curr_value: f32 = 0, // NOTE : The initial value is Zero.

    pub const Inner = struct {
        outer: *Outer,
        pub fn init(self: *Inner, value: ?f32, size: Size) void {
            self.outer.curr_value = value orelse 1.0; // NOTE : Take value or else default to 1.
            self.outer.curr_value = switch (size) {
                .Small => self.outer.curr_value * 2,
                .Medium => self.outer.curr_value * 4,
                .Large => self.outer.curr_value * 8,
            };
        }

        // NOTE : This usually works after the init is called and used.
        // ? This will return 0 when we don't use init.
        pub fn returnValue(self: *Inner) !f32 {
            return self.outer.curr_value;
        }
    };
};

pub fn main(init: std.process.Init) !void {
    _ = init;
}
