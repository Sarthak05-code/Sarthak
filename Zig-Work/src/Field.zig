const std = @import("std");

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

pub fn main() void {
    // Create a value by supplying each struct field.
    var player = Player{
        .name = "Sarthak",
        .score = 10,
    };

    player.addPoints(5);
    player.print(); // Prints: Sarthak has 15 points
}
