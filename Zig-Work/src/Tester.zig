const std = @import("std");

const Errors = error{
    StackOverflow,
    RecursionLimit,
    ArrayOutOfBounds,
};

fn arrayReturn(array: [10]i32, index: usize) Errors!i32 {
    if (index >= array.len) {
        return Errors.ArrayOutOfBounds;
    }

    return array[index];
}

fn errorMessage(err: Errors) []const u8 {
    return switch (err) {
        Errors.StackOverflow => "Stack overflow occurred.",
        Errors.RecursionLimit => "Recursion limit reached.",
        Errors.ArrayOutOfBounds => "The requested array index does not exist.",
    };
}

pub fn main() !void {
    const array = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const index: usize = 12;

    const answer = arrayReturn(array, index) catch |err| {
        std.debug.print(
            "Error: {s}\n",
            .{errorMessage(err)},
        );
        return;
    };

    std.debug.print("Answer: {}\n", .{answer});
}