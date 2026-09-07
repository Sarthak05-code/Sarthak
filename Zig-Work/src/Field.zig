const std = @import("std");

const G = 9.85;
const X = 3.0;
const Y = 4.0;
const MASS_ASSUMED = 0.18;

pub const Quasar = struct {
    pub const Types = enum {
        small,
        medium,
        large,
    };

    pub fn displacement(
        self: *Quasar,
        x: f32,
        y: f32,
        mass: f32,
        depth: ?f32,
        planet_type: Types,
    ) void {
        _ = self;

        // Choose multiplier based on enum value
        const multiplier: f32 = switch (planet_type) {
            .small => 1,
            .medium => 2,
            .large => 4,
        };

        // Calculate altered mass
        const mass_altered = mass * MASS_ASSUMED * multiplier;

        std.debug.print(
            "Planet: {s}, Mass altered: {d}\n",
            .{ @tagName(planet_type), mass_altered },
        );

        // If depth is null, use 1
        const deep = depth orelse 1;

        const dX = X - x;
        const dY = Y - y;

        const displacement_value =
            (dY * dX) / mass_altered * deep;

        if (displacement_value == 0) { // no change means the same acceleration
            std.debug.print(
                "You are moving at the same speed: {d}\n",
                .{displacement_value},
            );
        } else if (displacement_value < 0) { // Negative means, your normal speed vs the current speed being subtracted and the result being how much is the difference.
            std.debug.print(
                "You are going faster than usual: {d}\n",
                .{displacement_value},
            );
        } else { // here we understand the person speed didnt increase but decrease.
            std.debug.print(
                "You are going slower than usual: {d}\n",
                .{displacement_value},
            );
        }
    }

    pub const Temperature = struct {
        pub fn gravity(
            self: *Temperature,
            mass: f32,
            acceleration: ?f32,
        ) void {
            _ = self;

            const acc = acceleration orelse 1;
            const velocity = mass * acc * G;

            std.debug.print(
                "Gravity value: {d}\n",
                .{velocity},
            );
        }
    };
};
