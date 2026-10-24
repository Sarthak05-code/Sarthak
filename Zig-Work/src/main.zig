const std = @import("std");

const Element = enum {
    Physical,
    Fire,
    Wind,
    Lightning,
    Imaginary,
    Quantum,
    Ice,
};

const Role = enum {
    Attacker,
    Support,
    Tank,
    Debuffer,
};

const CharacterIndex = struct {
    character_id: u64,
    character_name: []const u8,
    character_gender: ?[]const u8,
    element_type: Element,
    faction: []const u8,
    mechanics: Role,
};

pub fn main() !void {
    // A team can contain up to 4 characters.
    // null means that the slot is currently empty.
    var character: [4]?CharacterIndex = .{
        null,
        null,
        null,
        null,
    };

    character[0] = CharacterIndex{
        .character_id = 101,
        .character_name = "Sarthak",
        .character_gender = "Male",
        .element_type = .Wind,
        .faction = "A.V.M",
        .mechanics = .Attacker,
    };
}
