const std = @import("std");

pub const Rectangle = struct {
    a: usize,
    b: usize,

    pub fn init(a: usize, b: usize) Rectangle {
        return .{ .a = a, .b = b };
    }

    pub fn area(self: Rectangle) usize {
        return self.a * self.b;
    }

    pub fn scale(self: *Rectangle, factor: usize) void {
        self.a *= factor;
        self.b *= factor;
    }
};

pub const Advance = struct {
    current_pos: usize = 0,

    pub fn advance(self: *Advance) void {
        self.current_pos += 1;
    }

    pub fn descend(self: *Advance) void {
        if (self.current_pos > 0) {
            self.current_pos -= 1;
        }
    }

    pub fn scalable_advance(self: *Advance, steps: usize) void {
        self.current_pos += steps;
    }

    pub fn scalable_descend(self: *Advance, steps: usize) void {
        self.current_pos = if (self.current_pos >= steps)
            self.current_pos - steps
        else blk: {
            std.debug.print("Not possible to descend below 0\n", .{});
            break :blk 0;
        };
    }

    pub fn reset(self: *Advance) void {
        self.current_pos = 0;
    }
};



pub fn main() !void {
    var shape = Rectangle.init(12, 10);
    const initial_area = shape.area();
    std.debug.print("Initial Area: {}\n", .{initial_area});

    shape.scale(2);
    const new_area = shape.area();
    std.debug.print("Scaled Area:  {}\n", .{new_area});

    var pos: Advance = .{};
    pos.descend();
    std.debug.print("Current pos : {}\n", .{pos.current_pos});

    pos.advance();
    std.debug.print("Current pos : {}\n", .{pos.current_pos});

    pos.scalable_advance(3);
    std.debug.print("Current steps : {}\n", .{pos.current_pos});

    pos.scalable_descend(5);
    std.debug.print("Current steps : {}\n", .{pos.current_pos});
}
