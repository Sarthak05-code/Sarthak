const std = @import("std");

pub const LimitTest = enum { Minor, Major, Viral, Universal };

pub const LoadBalancer = struct {
    children: u32 = 1,
    const max_attendance: u64 = 1000;

    pub fn syncLimitTest(self: *LoadBalancer, size: LimitTest) void {
        self.children = switch (size) {
            .Minor => 1,
            .Major => 4,
            .Viral => 10,
            .Universal => 25,
        };
    }

    pub fn addTraffic(self: *LoadBalancer, visitors: ?u64) void {
        const users = visitors orelse 100;

        const limit: LimitTest = switch (users) {
            0...100 => .Minor,
            101...1000 => .Major,
            1001...10_000 => .Viral,
            else => .Universal,
        };

        // 1. Set the base children tier first
        self.syncLimitTest(limit);

        // 2. Safely calculate overflow without underflowing
        if (users > max_attendance) {
            const overflow = users - max_attendance;
            self.createAdditionalBalancer(overflow);
        }
    }

    pub fn createAdditionalBalancer(self: *LoadBalancer, overflow_users: u64) void {
        // Direct O(1) integer division replacing the unsafe loop
        const extra_kids = @as(u32, @intCast(overflow_users / 1000));
        self.children += extra_kids;
    }
};

pub fn main(init: std.process.Init) !void {
    _ = init;

    var ld: LoadBalancer = .{};

    // 1. Default (100 visitors) -> Minor tier -> 1 child
    ld.addTraffic(null);
    std.debug.print("Default (100 visitors) -> Children: {}\n", .{ld.children});

    // 2. 500 visitors -> Major tier -> 4 children
    ld.addTraffic(500);
    std.debug.print("500 visitors -> Children: {}\n", .{ld.children});

    // 3. 1,000,000 visitors -> Universal base (25) + Overflow extra (999) -> 1024 children
    ld.addTraffic(1_000_000);
    std.debug.print("1,000,000 visitors -> Children: {}\n", .{ld.children});
}


