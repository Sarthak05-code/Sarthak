const std = @import("std");

const Login = struct { sucess: bool, client_id: i32, role: []const u8 };

fn login(email: []const u8, password: []const u8) !Login {
    _ = password;

    if (std.mem.eql(u8, email, "ytsarthak1@gmail.com")) {
        return .{ .sucess = true, .client_id = 101, .role = "client" };
    }
    return .{ .sucess = false, .client_id = 0, .role = "guest" };
}

pub fn main(init: std.process.Init) !void {
    _ = init;
    const value = try login("ytsarthak1@gmail.com", "123456sarthak");
    if (value.sucess) {
        std.debug.print("Login sucessfull. Hello, {s}\n", .{value.role});
    } else {
        std.debug.print("Login unsuccessfull, hello {s}\n", .{value.role});
    }
}
