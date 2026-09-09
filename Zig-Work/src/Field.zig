const std = @import("std");

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
}

// A struct groups related values into one custom type.
const Player = struct {
    name: []const u8,
    score: u32,

    // Functions declared inside a struct are methods.
    fn addPoints(self: *Player, points: u32) void {
        self.score += points;
    }

    fn print(self: Player) void {
        std.debug.print("{s} has {d} points\n", .{ self.name, self.score });
    }
};
