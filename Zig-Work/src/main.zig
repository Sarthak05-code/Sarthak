const std = @import("std");

const ArrayList = std.ArrayList;



pub fn StructFallBack() type {
    return struct {
        arena: std.heap.ArenaAllocator,

        pub fn init() @This() {
            return .{
                .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
            };
        }

        pub fn Values(self: *@This()) void {
            const allocator = self.arena.allocator();

            _ = allocator;

            std.debug.print("The values are initialized here.\n", .{});
        }

        pub fn deinit(self: *@This()) void {
            std.debug.print("The value was freed here.\n", .{});
            self.arena.deinit();
        }
    };
}

pub fn main(init: std.process.Init) !void {
    _ = init;

    const gpa = std.heap.page_allocator;
    var values: ArrayList(f32) = .empty;
    defer values.deinit(gpa);

    try values.append(gpa, 12.34);
    try values.append(gpa, 122.343);
    try values.append(gpa, 1222.3422);
    var i: usize = 0;
    for (values.items) |value| {
        std.debug.print("{}. {}\n", .{ i + 1, value });
        i += 1;
    }

    const CallStruct = StructFallBack();

    var data = CallStruct.init();
    defer data.deinit();

    data.Values();
}
