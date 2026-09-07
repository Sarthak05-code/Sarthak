const std = @import("std");
const Field = @import("Field.zig");

pub fn main() !void {
    var jupiter: Field.Quasar.Temperature = .{};
    jupiter.gravity(10, null);

    var coordinate: Field.Quasar = .{};
    coordinate.displacement(5, 2, 22, null, .small);
    coordinate.displacement(5, 2, 22, null, .medium);
    coordinate.displacement(5, 2, 22, null, .large);
}
