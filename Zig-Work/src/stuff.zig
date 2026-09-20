const TestError = error{TestErrorHere};

const std = @import("std");

pub fn returnError(int: i32) TestError!i32 {
    if (int > 0) return TestError.TestErrorHere;
    return int + 10;
}

pub fn main(init: std.process.Init) !void {
    _ = init;
    const number = 10;
    const answer = returnError(number) catch |err| {
        std.debug.print("Error. \n", .{err});
    };
    std.debug.print("Number is {} \n", .{answer});
}
