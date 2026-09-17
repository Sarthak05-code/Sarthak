const std = @import("std");

const Invalid = error{ EmptyValues, InvalidUserLogin, SamePassword };

var ID: i32 = 100;

const Register = struct {
    username: []const u8,
    password: []const u8,
    email: []const u8,
    client_id: i32,
};

const Login = struct {
    email: []const u8,
    password: []const u8,
};

fn createUser(
    username: ?[]const u8,
    password: []const u8,
    email: []const u8,
) Invalid!Register {
    const set_username = username orelse "defaultuser123";

    if (password.len == 0 or email.len == 0)
        return Invalid.EmptyValues;

    const user = Register{
        .client_id = ID,
        .username = set_username,
        .password = password,
        .email = email,
    };

    ID += 1;

    return user;
}

fn showUser(users: []const Register, client_id: i32) Invalid!Login {
    for (users) |user| {
        if (user.client_id == client_id) {
            return .{
                .email = user.email,
                .password = user.password,
            };
        }
    }

    return Invalid.InvalidUserLogin;
}

fn changePassword(
    new_password: []const u8,
    client_id: i32,
    users: []Register,
) !void {
    if (new_password.len == 0) {
        return Invalid.EmptyValues;
    }

    for (users) |*user| {
        if (user.client_id == client_id) {
            if (std.mem.eql(u8, user.password, new_password)) {
                return Invalid.SamePassword;
            }

            user.password = new_password;
            return;
        }
    }

    return Invalid.InvalidUserLogin;
}

pub fn main() !void {
    var users: [3]Register = undefined;

    users[0] = try createUser(
        "Sarthak",
        "pass123",
        "sarthak@example.com",
    );

    users[1] = try createUser(
        "Alice",
        "alice123",
        "alice@example.com",
    );

    users[2] = try createUser(
        "Bob",
        "bob123",
        "bob@example.com",
    );

    const login = try showUser(users[0..], 101);

    std.debug.print(
        "Email: {s}\nPassword: {s}\n",
        .{ login.email, login.password },
    );

    try changePassword("bobber123", 102, &users);
    const bob_login = try showUser(users[0..], 102);
    std.debug.print("Email : {s} | Password : {s}\n", .{ bob_login.email, bob_login.password });
}
