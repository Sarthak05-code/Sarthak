//! Small utility library for common string and slice operations.
//!
//! Most text functions trim leading and trailing whitespace before
//! doing their check. The generic helpers do not.
//!
//! Example:
//! ```zig
//! const lib = @import("Zig_Work");
//!
//! if (lib.contains("  hello world  ", "world")) {
//!     lib.println("found");
//! }
//! ```

const std = @import("std");

/// Helpers for writing CSV data. See `Csv.zig`.
pub const csv = @import("Csv.zig");

/// Whitespace characters used by the trim helpers.
const whitespace = std.ascii.whitespace;

/// Vowel characters used by `isVowel`.
const vowels = "aeiouAEIOU";

/// Short alias for `std.debug.print`.
///
/// Takes a format string and a tuple of arguments, and prints to stderr.
/// Always pass the arguments tuple, even when it is empty: `print("hi\n", .{})`.
pub const print = std.debug.print;

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
/// For other types, use `containsG`.
pub fn contains(text: []const u8, value: []const u8) bool {
    return std.mem.indexOf(u8, trim(text), value) != null;
}

/// Generic version of `contains`.
///
/// Returns true if `needle` appears as a contiguous sub-slice inside `haystack`.
/// Works for any type `T` that supports equality comparison.
/// Unlike `contains`, it does not trim anything.
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

/// Returns true if `char` is an English vowel (a, e, i, o, u).
/// The check is case-insensitive.
pub fn isVowel(char: u8) bool {
    return std.mem.findScalar(u8, vowels, char) != null;
}

// Checks that `isVowel` returns true for vowels in both cases.
test "isVowel returns true for vowels" {
    try std.testing.expect(isVowel('a'));
    try std.testing.expect(isVowel('E'));
    try std.testing.expect(isVowel('i'));
    try std.testing.expect(isVowel('O'));
    try std.testing.expect(isVowel('u'));
}

// Checks that `isVowel` returns false for consonants, spaces, and digits.
test "isVowel returns false for consonants" {
    try std.testing.expect(!isVowel('b'));
    try std.testing.expect(!isVowel('Z'));
    try std.testing.expect(!isVowel('x'));
    try std.testing.expect(!isVowel(' '));
    try std.testing.expect(!isVowel('1'));
}

// Checks that `containsG` works with integers.
test "containsG works with integers" {
    const nums = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const needle = [_]i32{ 3, 4 };
    const outside = [_]i32{ 10, 100 };

    try std.testing.expect(containsG(i32, &nums, &needle));
    try std.testing.expect(!containsG(i32, &nums, &outside));
}

// Makes `zig build test` also run the tests inside `Csv.zig`.
test {
    _ = csv;
}
