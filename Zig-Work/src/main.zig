const std = @import("std");
const Field = @import("Field.zig");

pub fn main(init: std.process.Init) !void {
    _ = init;

    var name: Field.Name = .{
        .first_name = "Sarthak",
        .last_name = "Thapa",
    };

    Field.Name.NameUtlis.middle_name(&name, "Kumar");
    Field.Name.NameUtlis.middle_name(&name, null);


    
}
