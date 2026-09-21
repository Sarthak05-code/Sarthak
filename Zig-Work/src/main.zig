const std = @import("std");

pub const LimitTest = enum { Minor, Major, Viral, Universal };
pub const UniversalHealthState = enum { Healthy, Unstable, FailurePoint };

pub const LoadBalancer = struct {
    children: u32 = 1,
    pressureState: bool = false,
    total_user: u64 = 0,
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
        self.total_user += users;

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

    pub fn pressureLoadBalancer(self: *LoadBalancer, pressure: ?bool) void {
        self.pressureState = pressure orelse false;
    }

    pub fn panicCrash(self: *const LoadBalancer, users: u64) void {
        if (self.pressureState and users > max_attendance) {
            var buffer: [256]u8 = undefined;
            const message = std.fmt.bufPrint(
                &buffer,
                \\CRITICAL OVERLOAD: LoadBalancer collapsed under pressure!
                \\  - Incoming Users: {}
                \\  - Active Workers: {}
                \\  - Max Capacity:   {}
                \\  - Overflow:      {} users unhandled
            ,
                .{ users, self.children, max_attendance, users - max_attendance },
            ) catch "CRITICAL OVERLOAD: LoadBalancer panic string formatting failed.";

            @panic(message);
        }
    }

    pub fn getStatus(self: *const LoadBalancer) void {
        const healthStatCalculate: u64 = @divFloor(self.total_user, self.children);

        const health = switch (healthStatCalculate) {
            0...100 => UniversalHealthState.Healthy,
            101...500 => UniversalHealthState.Unstable,
            else => UniversalHealthState.FailurePoint,
        };

        std.debug.print("--- Load Balancer Status ---\n", .{});
        std.debug.print("| Total Users   : {}\n", .{self.total_user});
        std.debug.print("| Active Workers: {}\n", .{self.children});
        std.debug.print("| System Health : {s}\n", .{@tagName(health)});
        std.debug.print("----------------------------\n", .{});
    }
};

pub fn main() !void {
    var ld: LoadBalancer = .{};

    // 1. Initial traffic
    ld.addTraffic(null);
    ld.getStatus();

    // 2. Heavy traffic without pressure mode
    ld.addTraffic(1500);
    ld.getStatus();

    // 3. Pressure mode ON (safe traffic)
    ld.pressureLoadBalancer(true);
    ld.addTraffic(200);
    ld.getStatus();
}
