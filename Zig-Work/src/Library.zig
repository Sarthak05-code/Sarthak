//! Small utility library for common string and slice operations.
//!
//! Most text functions automatically trim leading/trailing whitespace
//! before performing the check. The generic helpers do not.
//!
//! Example:
//! ```zig
//! const lib = @import("Library.zig");
//!
//! if (lib.contains("  hello world  ", "world")) {
//!     lib.println("found");
//! }
//! ```

const std = @import("std");

/// Whitespace characters used by the trim helpers.
/// Prefer `std.ascii.whitespace` as it is more complete than a manual list.
const whitespace = std.ascii.whitespace;

/// Vowel characters used by the isVowel helper.
const vowels = "aeiouAEIOU";

/// Returns a sub-slice of `text` with leading and trailing whitespace removed.
/// Does not allocate.
pub fn trim(text: []const u8) []const u8 {
    return std.mem.trim(u8, text, whitespace[0..]);
}

/// Returns true if the trimmed `text` starts with `prefix`.
pub fn startsWith(text: []const u8, prefix: []const u8) bool {
    return std.mem.startsWith(u8, trim(text), prefix);
}

/// Returns true if the trimmed `text` ends with `suffix`.
pub fn endsWith(text: []const u8, suffix: []const u8) bool {
    return std.mem.endsWith(u8, trim(text), suffix);
}

/// Prints `text` followed by a newline to stderr (debug output).
pub fn println(text: []const u8) void {
    std.debug.print("{s}\n", .{text});
}

/// Returns true if `text` is empty or contains only whitespace.
pub fn isBlank(text: []const u8) bool {
    return trim(text).len == 0;
}

/// Returns true if the trimmed `text` contains `value` as a substring.
///
/// This is the convenient string-only version.
/// For other types use `containsG`.
pub fn contains(text: []const u8, value: []const u8) bool {
    return std.mem.indexOf(u8, trim(text), value) != null;
}

/// Generic version of `contains`.
///
/// Returns true if `needle` appears as a contiguous sub-slice inside `haystack`.
/// Works for any type `T` that supports equality.
///
/// Example:
/// ```zig
/// const nums = [_]i32{ 1, 2, 3, 4, 5 };
/// if (containsG(i32, &nums, &[_]i32{ 3, 4 })) {
///     // found
/// }
/// ```
pub fn containsG(comptime T: type, haystack: []const T, needle: []const T) bool {
    return std.mem.indexOf(T, haystack, needle) != null;
}

/// Returns true if `char` is an English vowel (a, e, i, o, u), case-insensitive.
pub fn isVowel(char: u8) bool {
    return std.mem.findScalar(u8, vowels, char) != null;
}

// Testing the function to ensure the output is as expected.
test "isVowel returns true for vowels" {
    try std.testing.expect(isVowel('a'));
    try std.testing.expect(isVowel('E'));
    try std.testing.expect(isVowel('i'));
    try std.testing.expect(isVowel('O'));
    try std.testing.expect(isVowel('u'));
}

// Testing the function to ensure the output is correct.
test "isVowel returns false for consonants" {
    try std.testing.expect(!isVowel('b'));
    try std.testing.expect(!isVowel('Z'));
    try std.testing.expect(!isVowel('x'));
    try std.testing.expect(!isVowel(' '));
    try std.testing.expect(!isVowel('1'));
}

test "containsG works with integer" {
    const nums = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const needle = [_]i32{ 3, 4 };
    const outside = [_]i32{10, 100};

    try std.testing.expect(containsG(i32, &nums, &needle));
    
    try std.testing.expect(!containsG(i32, &nums, &outside));
}
