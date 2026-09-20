const std = @import("std");

const ArrayList = std.ArrayList;

pub const LimitTest = enum { Minor, Major, Viral };

pub const LoadBalancer = struct {
    children: i32 = 1, // have atleast 1 kid ready.

    pub fn syncLimitTest(self: *LoadBalancer, size: LimitTest) void {
        switch (size) {
            .Minor => self.children = 1,
            .Major => self.children = 4,
            .Viral => self.children = 10, // assume all of a sudden a million people join, so viral has more than major.
        }
    }

    pub fn addTraffic(self: *LoadBalancer, visitors: ?i64) i32 {
        const users = visitors orelse 100; // default to understand we have about 100 users.

        const limit: LimitTest = switch (users) {
            0...100 => .Minor,
            101...1000 => .Major,
            else => .Viral,
        };

        self.syncLimitTest(limit);

        return self.children;
    }
};

pub fn main(init: std.process.Init) !void {
    _ = init;

    var ld: LoadBalancer = .{};
    std.debug.print("Childern current: {}\n", .{ld.children});
    const kids = ld.addTraffic(null);
    std.debug.print("Load Test : {any}\n", .{kids});
}
