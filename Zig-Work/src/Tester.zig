const std = @import("std");

const Errors = error{
    StackOverflow,
    RecursionLimit,
    ArrayOutOfBounds,
};
// INFO : Here is a comment.
fn arrayReturn(array: [10]i32, index: usize) Errors!i32 {
    if (index >= array.len) {
        return Errors.ArrayOutOfBounds;
    }

    return array[index];
}
// TODO : Add more error here.
fn errorMessage(err: Errors) []const u8 {
    return switch (err) {
        Errors.StackOverflow => "Stack overflow occurred.",
        Errors.RecursionLimit => "Recursion limit reached.",
        Errors.ArrayOutOfBounds => "The requested array index does not exist.",
    };
}

// WARNING : Code can break if we add to big of a number.
fn recursion(x: i64, depth: usize) Errors!i64 {
    if (depth > 100)
        return Errors.RecursionLimit;

    if (x <= 1)
        return x;

    return try recursion(x - 2, depth + 1) + try recursion(x - 1, depth + 1);
}

pub fn main() !void {
    const array = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const index: usize = 1;
    const answer = arrayReturn(array, index) catch |err| {
        std.debug.print(
            "Error: {s}\n",
            .{errorMessage(err)},
        );
        return;
    };

    const recAnswer = recursion(40, 0) catch |err| {
        std.debug.print("Error: {s}\n", .{errorMessage(err)});
        return;
    };

    std.debug.print("Answer: {}\n", .{answer});
    std.debug.print("Answer: {}\n", .{recAnswer});
}
