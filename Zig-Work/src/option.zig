const std = @import("std");

pub const Circle = struct {
    a: usize,
    b: usize,

    // 1. Constructor / Static Function
    // No `self` parameter. Called directly on the namespace: Circle.init(...)
    pub fn init(a: usize, b: usize) Circle {
        return Circle{
            .a = a,
            .b = b,
        };
    }

    // 2. Read-Only Method
    // Takes `self: *const Circle` (or `self: Circle`). Can read, but cannot modify fields.
    pub fn area(self: *const Circle) usize {
        return self.a * self.b;
    }

    // 3. Mutating Method
    // Takes `self: *Circle`. Requires the target instance to be declared with `var`.
    pub fn scale(self: *Circle, factor: usize) void {
        self.a *= factor;
        self.b *= factor;
    }
};

pub fn main() void {
    // Calling Constructor
    var shape = Circle.init(12, 10);

    // Calling Read-Only Method
    const initial_area = shape.area();
    std.debug.print("Initial Area: {}\n", .{initial_area}); // 120

    // Calling Mutating Method
    shape.scale(2); // Modifies shape.a to 24 and shape.b to 20

    const new_area = shape.area();
    std.debug.print("Scaled Area:  {}\n", .{new_area}); // 480
}
