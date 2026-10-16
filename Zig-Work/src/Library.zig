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

/// Short alias for `std.debug.print`.
///
/// Takes a format string and a tuple of arguments, and prints to stderr.
/// Always pass the arguments tuple, even when it is empty: `print("hi\n", .{})`.
pub const print = std.debug.print;

// ---------------------------------------------------------------------------
// Text helpers
// ---------------------------------------------------------------------------

/// Returns a sub-slice of `text` with leading and trailing whitespace removed.
/// Does not allocate.
pub fn trim(text: []const u8) []const u8 {
    return std.mem.trim(u8, text, &std.ascii.whitespace);
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
    print("{s}\n", .{text});
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
    return containsG(u8, trim(text), value);
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
    return std.mem.find(T, haystack, needle) != null;
}

/// Returns true if `char` is an English vowel (a, e, i, o, u).
/// The check is case-insensitive.
pub fn isVowel(char: u8) bool {
    return switch (std.ascii.toLower(char)) {
        'a', 'e', 'i', 'o', 'u' => true,
        else => false,
    };
}

// ---------------------------------------------------------------------------
// Binary tree
// ---------------------------------------------------------------------------

/// A node of a binary tree holding an `i64`.
///
/// Nodes are heap-allocated with `init` and must be released with `destroy`,
/// which frees the node and everything below it.
pub const Node = struct {
    data: i64,
    left: ?*Node = null,
    right: ?*Node = null,

    /// Allocates a leaf node holding `data`. Free it with `destroy`.
    pub fn init(allocator: std.mem.Allocator, data: i64) !*Node {
        const node = try allocator.create(Node);
        node.* = .{ .data = data };
        return node;
    }

    /// Frees this node and its whole subtree (children first, then the node).
    /// The node must not be used afterwards.
    pub fn destroy(self: *Node, allocator: std.mem.Allocator) void {
        if (self.left) |left| left.destroy(allocator);
        if (self.right) |right| right.destroy(allocator);
        allocator.destroy(self);
    }
};

/// Visits the tree in pre-order: root, left, right.
///
/// `visitor` must be a pointer to a type with a `visit(self, value: i64) void`
/// method. Does nothing when `node` is null.
pub fn preOrderVisit(node: ?*const Node, visitor: anytype) void {
    const current = node orelse return;
    visitor.visit(current.data);
    preOrderVisit(current.left, visitor);
    preOrderVisit(current.right, visitor);
}

/// Visits the tree in in-order: left, root, right.
/// For a binary search tree this yields the values in sorted order.
/// See `preOrderVisit` for the `visitor` contract.
pub fn inOrderVisit(node: ?*const Node, visitor: anytype) void {
    const current = node orelse return;
    inOrderVisit(current.left, visitor);
    visitor.visit(current.data);
    inOrderVisit(current.right, visitor);
}

/// Visits the tree in post-order: left, right, root.
/// See `preOrderVisit` for the `visitor` contract.
pub fn postOrderVisit(node: ?*const Node, visitor: anytype) void {
    const current = node orelse return;
    postOrderVisit(current.left, visitor);
    postOrderVisit(current.right, visitor);
    visitor.visit(current.data);
}

/// Visitor that prints each value followed by a space to stderr.
const PrintVisitor = struct {
    pub fn visit(_: *PrintVisitor, value: i64) void {
        print("{d} ", .{value});
    }
};

/// Prints the tree in pre-order (root, left, right) to stderr.
pub fn preOrder(node: ?*const Node) void {
    var visitor: PrintVisitor = .{};
    preOrderVisit(node, &visitor);
}

/// Prints the tree in in-order (left, root, right) to stderr.
pub fn inOrder(node: ?*const Node) void {
    var visitor: PrintVisitor = .{};
    inOrderVisit(node, &visitor);
}

/// Prints the tree in post-order (left, right, root) to stderr.
pub fn postOrder(node: ?*const Node) void {
    var visitor: PrintVisitor = .{};
    postOrderVisit(node, &visitor);
}

// ---------------------------------------------------------------------------
// Searching
// ---------------------------------------------------------------------------

/// Linear search over scalar types (integers, floats, bools, enums).
///
/// Returns true if `needle` is in `array`. The array may be in any order.
/// Uses `==`, so it does not work for slices such as strings;
/// use `linearSearchStr` for those.
pub fn linearSearch(comptime T: type, array: []const T, needle: T) bool {
    for (array) |value| {
        if (value == needle) return true;
    }
    return false;
}

/// Linear search over a list of strings, comparing by content.
pub fn linearSearchStr(array: []const []const u8, needle: []const u8) bool {
    for (array) |value| {
        if (std.mem.eql(u8, value, needle)) return true;
    }
    return false;
}

/// Binary search over a **sorted (ascending)** `array`.
///
/// Returns true if `needle` is present. Works for any type that supports
/// `==` and `<` (integers and floats). On unsorted input the result is
/// meaningless. Runs in O(log n).
///
/// The search window is the half-open range `[low, high)`, so `high` never
/// needs `mid - 1` and `usize` can never underflow.
pub fn binarySearch(comptime T: type, array: []const T, needle: T) bool {
    var low: usize = 0;
    var high: usize = array.len;

    while (low < high) {
        const mid = low + (high - low) / 2;

        if (array[mid] == needle) return true;

        if (array[mid] < needle) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    return false;
}

// ---------------------------------------------------------------------------
// API tiers
// ---------------------------------------------------------------------------

/// Errors that `returnApiUsage` can produce.
pub const UsageError = error{InvalidTier} || std.mem.Allocator.Error;

/// A subscription tier of the simulated API.
pub const Tier = enum {
    free,
    paid,
    premium,

    /// Maximum number of API calls allowed for this tier.
    pub fn limit(self: Tier) u32 {
        return switch (self) {
            .free => 100,
            .paid => 500,
            .premium => 10_000,
        };
    }

    /// Parses a tier name, ignoring case ("Paid", "PAID" and "paid" all work).
    /// Returns null if `text` is not a tier name.
    pub fn parse(text: []const u8) ?Tier {
        // Longest tier name is "premium" (7 chars); anything longer cannot match.
        var buf: [16]u8 = undefined;
        if (text.len > buf.len) return null;
        return std.meta.stringToEnum(Tier, std.ascii.lowerString(&buf, text));
    }
};

/// API usage simulation. Returns "<name>'s limit is: <limit>".
///
/// A null `tier` means the free tier.
/// Returns `error.InvalidTier` for an unknown tier name.
/// Caller owns the returned memory and must free it with `allocator`.
pub fn returnApiUsage(
    allocator: std.mem.Allocator,
    name: []const u8,
    tier: ?[]const u8,
) UsageError![]u8 {
    const parsed: Tier = if (tier) |text|
        Tier.parse(text) orelse return error.InvalidTier
    else
        .free;

    return std.fmt.allocPrint(allocator, "{s}'s limit is: {d}", .{ name, parsed.limit() });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// Makes `zig build test` also run the tests inside `Csv.zig`.
test {
    _ = csv;
}

test "trim removes surrounding whitespace only" {
    try std.testing.expectEqualStrings("hi", trim("  hi \n"));
    try std.testing.expectEqualStrings("a b", trim("\ta b\t"));
    try std.testing.expectEqualStrings("", trim("   "));
    try std.testing.expectEqualStrings("", trim(""));
}

test "startsWith and endsWith ignore surrounding whitespace" {
    try std.testing.expect(startsWith("  hello world", "hello"));
    try std.testing.expect(!startsWith("  hello world", "world"));
    try std.testing.expect(endsWith("hello world  \n", "world"));
    try std.testing.expect(!endsWith("hello world  ", "hello"));
}

test "isBlank" {
    try std.testing.expect(isBlank(""));
    try std.testing.expect(isBlank("  \t\n"));
    try std.testing.expect(!isBlank(" a "));
}

test "contains trims the text before searching" {
    try std.testing.expect(contains("  hello world  ", "world"));
    try std.testing.expect(contains("hello", "hello"));
    try std.testing.expect(!contains("  hello  ", "bye"));
    try std.testing.expect(!contains("", "x"));
}

test "containsG works with integers" {
    const nums = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const needle = [_]i32{ 3, 4 };
    const outside = [_]i32{ 10, 100 };
    const out_of_order = [_]i32{ 4, 3 };

    try std.testing.expect(containsG(i32, &nums, &needle));
    try std.testing.expect(!containsG(i32, &nums, &outside));
    try std.testing.expect(!containsG(i32, &nums, &out_of_order));
}

test "containsG does not trim" {
    try std.testing.expect(!containsG(u8, "  hello  ", "hello  x"));
    try std.testing.expect(containsG(u8, "  hello  ", " hello "));
}

test "isVowel returns true for vowels in both cases" {
    for ("aeiouAEIOU") |char| {
        try std.testing.expect(isVowel(char));
    }
}

test "isVowel returns false for consonants, spaces and digits" {
    for ("bZx 1y-") |char| {
        try std.testing.expect(!isVowel(char));
    }
}

/// Test helper: records visited values in order.
const Collector = struct {
    items: [16]i64 = undefined,
    len: usize = 0,

    pub fn visit(self: *Collector, value: i64) void {
        self.items[self.len] = value;
        self.len += 1;
    }

    fn values(self: *const Collector) []const i64 {
        return self.items[0..self.len];
    }
};

/// Test helper: builds this tree and returns its root.
///
///           4
///         /   \
///        2     6
///       / \   / \
///      1   3 5   7
fn buildSampleTree(allocator: std.mem.Allocator) !*Node {
    const root = try Node.init(allocator, 4);
    errdefer root.destroy(allocator);

    root.left = try Node.init(allocator, 2);
    root.right = try Node.init(allocator, 6);
    root.left.?.left = try Node.init(allocator, 1);
    root.left.?.right = try Node.init(allocator, 3);
    root.right.?.left = try Node.init(allocator, 5);
    root.right.?.right = try Node.init(allocator, 7);
    return root;
}

test "Node init and destroy do not leak" {
    const allocator = std.testing.allocator;
    const root = try Node.init(allocator, 42);
    defer root.destroy(allocator);

    try std.testing.expectEqual(@as(i64, 42), root.data);
    try std.testing.expect(root.left == null);
    try std.testing.expect(root.right == null);
}

test "pre-order traversal" {
    const root = try buildSampleTree(std.testing.allocator);
    defer root.destroy(std.testing.allocator);

    var c: Collector = .{};
    preOrderVisit(root, &c);
    try std.testing.expectEqualSlices(i64, &.{ 4, 2, 1, 3, 6, 5, 7 }, c.values());
}

test "in-order traversal" {
    const root = try buildSampleTree(std.testing.allocator);
    defer root.destroy(std.testing.allocator);

    var c: Collector = .{};
    inOrderVisit(root, &c);
    try std.testing.expectEqualSlices(i64, &.{ 1, 2, 3, 4, 5, 6, 7 }, c.values());
}

test "post-order traversal" {
    const root = try buildSampleTree(std.testing.allocator);
    defer root.destroy(std.testing.allocator);

    var c: Collector = .{};
    postOrderVisit(root, &c);
    try std.testing.expectEqualSlices(i64, &.{ 1, 3, 2, 5, 7, 6, 4 }, c.values());
}

test "traversals of an empty tree visit nothing" {
    var c: Collector = .{};
    preOrderVisit(null, &c);
    inOrderVisit(null, &c);
    postOrderVisit(null, &c);
    try std.testing.expectEqual(@as(usize, 0), c.len);
}

test "linearSearch works for integers, floats and unsorted input" {
    try std.testing.expect(linearSearch(i32, &.{ 9, 1, 5 }, 5));
    try std.testing.expect(!linearSearch(i32, &.{ 9, 1, 5 }, 2));
    try std.testing.expect(linearSearch(f64, &.{ 1.5, 2.5 }, 2.5));
    try std.testing.expect(!linearSearch(u8, &.{}, 1));
}

test "linearSearchStr compares string contents" {
    const words = [_][]const u8{ "zig", "rust", "go" };
    try std.testing.expect(linearSearchStr(&words, "rust"));
    try std.testing.expect(!linearSearchStr(&words, "c"));
    try std.testing.expect(!linearSearchStr(&.{}, "zig"));
}

test "binarySearch finds present values" {
    const odd = [_]i32{ 1, 3, 5, 7, 9 };
    for (odd) |value| {
        try std.testing.expect(binarySearch(i32, &odd, value));
    }

    const even = [_]i32{ 2, 4, 6, 8 };
    for (even) |value| {
        try std.testing.expect(binarySearch(i32, &even, value));
    }
}

test "binarySearch rejects absent values, including below and above the range" {
    const nums = [_]i32{ 1, 3, 5, 7 };
    try std.testing.expect(!binarySearch(i32, &nums, 0));
    try std.testing.expect(!binarySearch(i32, &nums, 4));
    try std.testing.expect(!binarySearch(i32, &nums, 8));
}

test "binarySearch edge cases: empty and single element" {
    try std.testing.expect(!binarySearch(i32, &.{}, 4));
    try std.testing.expect(binarySearch(i32, &.{4}, 4));
    try std.testing.expect(!binarySearch(i32, &.{4}, 3));
    try std.testing.expect(!binarySearch(i32, &.{4}, 5));
}

test "binarySearch works for other types" {
    try std.testing.expect(binarySearch(f64, &.{ 0.5, 1.5, 2.5 }, 1.5));
    try std.testing.expect(binarySearch(u8, "abcdef", 'd'));
    try std.testing.expect(!binarySearch(u8, "abcdef", 'z'));
}

test "Tier limits" {
    try std.testing.expectEqual(@as(u32, 100), Tier.free.limit());
    try std.testing.expectEqual(@as(u32, 500), Tier.paid.limit());
    try std.testing.expectEqual(@as(u32, 10_000), Tier.premium.limit());
}

test "Tier.parse ignores case and rejects unknown names" {
    try std.testing.expectEqual(Tier.paid, Tier.parse("paid").?);
    try std.testing.expectEqual(Tier.paid, Tier.parse("Paid").?);
    try std.testing.expectEqual(Tier.premium, Tier.parse("PREMIUM").?);
    try std.testing.expect(Tier.parse("gold") == null);
    try std.testing.expect(Tier.parse("") == null);
}

test "returnApiUsage formats the limit for each tier" {
    const allocator = std.testing.allocator;

    const paid = try returnApiUsage(allocator, "Sarthak", "Paid");
    defer allocator.free(paid);
    try std.testing.expectEqualStrings("Sarthak's limit is: 500", paid);

    const premium = try returnApiUsage(allocator, "Sarthak", "premium");
    defer allocator.free(premium);
    try std.testing.expectEqualStrings("Sarthak's limit is: 10000", premium);
}

test "returnApiUsage defaults to the free tier" {
    const allocator = std.testing.allocator;

    const msg = try returnApiUsage(allocator, "Sarthak", null);
    defer allocator.free(msg);
    try std.testing.expectEqualStrings("Sarthak's limit is: 100", msg);
}

test "returnApiUsage rejects an unknown tier" {
    try std.testing.expectError(
        error.InvalidTier,
        returnApiUsage(std.testing.allocator, "Sarthak", "gold"),
    );
}

// ---------------------------------------------------------------------------
// Console I/O
// ---------------------------------------------------------------------------

/// Buffered stdin/stdout in one place, to avoid repeating the setup in `main`.
///
/// Create it with `var con: Console = undefined; con.init(io);`.
/// Do not copy or move it after `init`: the reader and writer point at its buffers.
pub const Console = struct {
    stdin_buf: [1024]u8 = undefined,
    stdout_buf: [1024]u8 = undefined,
    stdin_reader: std.Io.File.Reader = undefined,
    stdout_writer: std.Io.File.Writer = undefined,

    pub fn init(self: *Console, io: std.Io) void {
        self.stdin_reader = std.Io.File.stdin().reader(io, &self.stdin_buf);
        self.stdout_writer = std.Io.File.stdout().writer(io, &self.stdout_buf);
    }

    /// Prints `prompt`, then reads one line and returns it trimmed.
    /// Returns null at end of input. The slice points into the internal
    /// buffer and is only valid until the next read.
    pub fn ask(self: *Console, prompt: []const u8) !?[]const u8 {
        const out = &self.stdout_writer.interface;
        try out.writeAll(prompt);
        try out.flush();

        const line = try self.stdin_reader.interface.takeDelimiter('\n') orelse return null;
        return trim(line);
    }

    /// Formatted print to stdout, flushed immediately.
    pub fn say(self: *Console, comptime fmt: []const u8, args: anytype) !void {
        const out = &self.stdout_writer.interface;
        try out.print(fmt, args);
        try out.flush();
    }
};

/// String comparison.
/// Uses the `contains` function to trim the text and return a boolean.
pub fn equals(string_one: []const u8, string_two: []const u8) bool {
    return contains(string_one, string_two);
}
