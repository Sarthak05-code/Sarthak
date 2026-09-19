const std = @import("std");

pub const DPS = struct {
    base_attack: i32,
    defence: i32,
    crit_rate: f32,
    crit_damage: f32,

    pub fn init(
        base_attack: ?i32,
        defence: ?i32,
        crit_rate: ?f32,
        crit_damage: ?f32,
    ) DPS {
        return .{
            .base_attack = base_attack orelse 1000,
            .defence = defence orelse 500,
            .crit_rate = crit_rate orelse 5.0,
            .crit_damage = crit_damage orelse 50.0,
        };
    }

    pub fn displayStats(self: DPS) void {
        std.debug.print("{} {} {} {}\n", .{
            self.base_attack,
            self.defence,
            self.crit_rate,
            self.crit_damage,
        });
    }
};

pub fn main(init: std.process.Init) !void {
    _ = init;

    const dps = DPS.init(1200, null, 17.0, 99.0);

    dps.displayStats();
}
