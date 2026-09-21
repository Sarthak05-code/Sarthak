const std = @import("std");

pub const LimitTest = enum { Minor, Major, Viral, Universal };

pub const LoadBalancer = struct {
    children: u32 = 1,
    pressureState: bool = false,
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

        if (self.pressureState) {
            self.syncLimitTest(.Minor);
            self.panicCrash(users);
        } else {
            self.syncLimitTest(limit);
            if (users > max_attendance) {
                const overflow = users - max_attendance;
                self.createAdditionalBalancer(overflow);
            }
        }
    }

    pub fn createAdditionalBalancer(self: *LoadBalancer, overflow_users: u64) void {
        const extra_kids: u32 = @intCast(@divFloor(overflow_users + 999, 1000));
        self.children += extra_kids;
    }

    /// Deliberately locks children at 1 to simulate high pressure under test
    pub fn pressureLoadBalancer(self: *LoadBalancer, pressure: ?bool) void {
        self.pressureState = pressure orelse false;
    }

    pub fn panicCrash(self: *const LoadBalancer, users: u64) void {
        // Triggers a panic with a full stack trace if pressure mode is active
        // and incoming traffic exceeds capacity.
        if (self.pressureState and users > max_attendance) {
            @panic("Fatal error! Load balancer unable to handle traffic under pressure state.");
        }
    }
};

pub fn main() !void {
    var ld: LoadBalancer = .{};

    // 1. Default (100 visitors) -> Minor tier -> 1 child
    ld.addTraffic(null);
    std.debug.print("Default (100 visitors) -> Children: {}\n", .{ld.children});

    ld.addTraffic(500);
    std.debug.print("500 visitors -> Children: {}\n", .{ld.children});

    ld.pressureLoadBalancer(true);
    ld.addTraffic(69420);
    std.debug.print("69420 visitors -> Children: {} (locked at 1 due to pressure mode)\n", .{ld.children});
}
