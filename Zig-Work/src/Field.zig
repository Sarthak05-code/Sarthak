const std = @import("std");
const heap = std.heap;
const allocator = heap.BrkAllocator;
const built = @import("builtin");
const os = built.os.tag;


pub const Name = struct {
    first_name: []const u8,
    last_name: []const u8,

    pub const NameUtlis = struct {
        pub fn middle_name(
            person: *Name,
            name: ?[]const u8,
        ) void {
            if (name) |middle| {
                std.debug.print("{s} {s} {s}\n", .{
                    person.first_name,
                    middle,
                    person.last_name,
                });
            } else {
                std.debug.print("{s} {s}\n", .{
                    person.first_name,
                    person.last_name,
                });
            }
        }
    };
};
