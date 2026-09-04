const std = @import("std");

const Base = enum { binary, decimal, octal, hexadecimal };

pub const NumberConversion = struct {
    pub fn toBase(number: usize, base: Base, buffer: []u8) []const u8 {
        return switch (base) {
            .binary => toBaseGeneric(number, 2, "01", buffer),
            .octal => toBaseGeneric(number, 8, "01234567", buffer),
            .decimal => toBaseGeneric(number, 10, "0123456789", buffer),
            .hexadecimal => toBaseGeneric(number, 16, "0123456789abcdef", buffer),
        };
    }
};

fn toBaseGeneric(number: usize, base: usize, digits: []const u8, buffer: []u8) []const u8 {
    // NOTE : Special case we make for number 0.
    if (number == 0) {
        buffer[0] = '0';
        return buffer[0..1];
    }

    var temp = number;
    var index: usize = 0;
    // NOTE : store the digits now (reverse order)
    while (temp > 0) {
        const remainder = @rem(temp, base);
        buffer[index] = digits[remainder];
        temp = @divFloor(temp, base);
        index += 1;
    }

    // NOTE : Reversal role here
    reverse(buffer[0..index]);
    return buffer[0..index];
}

fn reverse(buffer: []u8) void {
    if (buffer.len == 0) return;
    var left: usize = 0;
    var right: usize = buffer.len - 1;
    while (left < right) {
        const swap = buffer[left];
        buffer[left] = buffer[right];
        buffer[right] = swap;
        left += 1;
        right -= 1;
    }
}

pub fn main() !void {
    var buffer: [64]u8 = undefined;
    const binary = NumberConversion.toBase(123, .binary, &buffer);
    std.debug.print("Binary = {s}\n", .{binary});

    var buffer2: [64]u8 = undefined;
    const hex = NumberConversion.toBase(255, .hexadecimal, &buffer2);
    std.debug.print("Hex = {s}\n", .{hex});
}
