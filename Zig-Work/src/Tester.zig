const std = @import("std");

const Base = enum { binary, decimal, octal, hexadecimal };

pub const NumberConversion = struct {
    pub fn toBase(number: usize, base: Base, buffer: []u8) ![]const u8 {
        switch (base) {
            .binary => {
                // NOTE : Special case we make for number 0.
                if (number == 0) {
                    buffer[0] = '0';
                    return buffer[0..1];
                }
                const digits = "01";

                var temp = number;
                var index: usize = 0;

                // NOTE : store the binary now (reverse order)
                while (temp > 0) {
                    const remainder = @rem(temp, 2);
                    buffer[index] = digits[remainder];

                    temp = @divFloor(temp, 2);
                    index += 1;
                }

                // NOTE : Reversal role here
                var left: usize = 0;
                var right: usize = index - 1;

                while (left < right) {
                    const swap = buffer[left];
                    buffer[left] = buffer[right];
                    buffer[right] = swap;

                    left += 1;
                    right -= 1;
                }
                return buffer[0..index];
            },

            .decimal => {},
            .octal => {},
            .hexadecimal => {},
        }
    }
};

pub fn main() !void {
    var buffer: [64]u8 = undefined;

    const answer = try NumberConversion.toBase(123, .binary, &buffer);
    std.debug.print("Binary = {s}\n", .{answer});
}
