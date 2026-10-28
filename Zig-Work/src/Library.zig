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

    /// Automatically prints with a color code and resets it.
    pub fn sayColored(self: *Console, color: []const u8, comptime fmt: []const u8, args: anytype) !void {
        try self.sayStyled(color, fmt, args);
    }

    /// Prints test using any combination of ANSI colors and styles.
    pub fn sayStyled(self: *Console, style: []const u8, comptime fmt: []const u8, args: anytype) !void {
        const out = &self.stdout_writer.interface;

        try out.writeAll(style);

        errdefer out.writeAll(ColorAscii.reset) catch {};

        try out.print(fmt, args);
        try out.writeAll(ColorAscii.reset);
        try out.flush();
    }
};

/// String comparison.
/// Returns true if both strings are identical after trimming.
pub fn equals(string_one: []const u8, string_two: []const u8) bool {
    return std.mem.eql(u8, trim(string_one), trim(string_two));
}

/// Returns true if the trimmed `text` starts with `prefix`, ignoring ASCII case.
pub fn startsWithIgnoreCase(text: []const u8, prefix: []const u8) bool {
    return std.ascii.startsWithIgnoreCase(trim(text), prefix);
}

/// Returns true if the trimmed `text` ends with `suffix`, ignoring ASCII case.
pub fn endsWithIgnoreCase(text: []const u8, suffix: []const u8) bool {
    return std.ascii.endsWithIgnoreCase(trim(text), suffix);
}

/// Returns true if the trimmed `text` contains `value`, ignoring ASCII case.
pub fn containsIgnoreCase(text: []const u8, value: []const u8) bool {
    return std.ascii.indexOfIgnoreCase(trim(text), value) != null;
}

/// Returns true if both strings are equal after trimming, ignoring ASCII case.
pub fn equalsIgnoreCase(a: []const u8, b: []const u8) bool {
    return std.ascii.eqlIgnoreCase(trim(a), trim(b));
}

/// Returns true if `text` reads the same forwards and backwards,
/// ignoring case and any non-alphanumeric characters.
pub fn isPalindrome(text: []const u8) bool {
    var left: usize = 0;
    var right: usize = text.len; // half-open, like your binarySearch

    while (left < right) {
        if (!std.ascii.isAlphanumeric(text[left])) {
            left += 1;
            continue;
        }
        if (!std.ascii.isAlphanumeric(text[right - 1])) {
            right -= 1;
            continue;
        }
        if (std.ascii.toLower(text[left]) != std.ascii.toLower(text[right - 1])) return false;
        left += 1;
        right -= 1;
    }
    return true;
}

/// Number of levels in the tree. An empty tree has height 0.
pub fn height(node: ?*const Node) usize {
    const current = node orelse return 0;
    return 1 + @max(height(current.left), height(current.right));
}

/// Turns `text` into a URL-friendly slug.
///
/// Letters and digits are kept (lowercased). Every run of other characters
/// becomes a single `-`. No leading or trailing `-`. ASCII only.
/// Caller owns the returned memory and must free it with `allocator`.
pub fn slugify(allocator: std.mem.Allocator, text: []const u8) std.mem.Allocator.Error![]u8 {
    // A slug is never longer than the input, so `text.len` is a safe buffer size.
    const buf = try allocator.alloc(u8, text.len);
    defer allocator.free(buf);

    var len: usize = 0;
    var pending_dash = false;

    for (text) |char| {
        if (std.ascii.isAlphanumeric(char)) {
            // Only write the dash once we know a letter follows it,
            // and never at the very start.
            if (pending_dash and len > 0) {
                buf[len] = '-';
                len += 1;
            }
            pending_dash = false;

            buf[len] = std.ascii.toLower(char);
            len += 1;
        } else {
            pending_dash = true;
        }
    }

    // Copy only the used part into an exactly-sized allocation.
    return allocator.dupe(u8, buf[0..len]);
}

/// ANSI terminal colors and text styles.
///
/// Provides foreground colors, background colors, RGB colors,
/// text formatting styles, and reset sequences for terminal output.
pub const ColorAscii = struct {
    // ─────────────────────────────────────────
    // Standard foreground colors
    // ─────────────────────────────────────────

    /// Sets the foreground text color to black.
    pub const black = "\x1b[30m";

    /// Sets the foreground text color to red.
    pub const red = "\x1b[31m";

    /// Sets the foreground text color to green.
    pub const green = "\x1b[32m";

    /// Sets the foreground text color to yellow.
    pub const yellow = "\x1b[33m";

    /// Sets the foreground text color to blue.
    pub const blue = "\x1b[34m";

    /// Sets the foreground text color to magenta.
    pub const magenta = "\x1b[35m";

    /// Sets the foreground text color to cyan.
    pub const cyan = "\x1b[36m";

    /// Sets the foreground text color to white.
    pub const white = "\x1b[37m";

    // ─────────────────────────────────────────
    // Bright foreground colors
    // ─────────────────────────────────────────

    /// Sets the foreground text color to bright black (gray).
    pub const bright_black = "\x1b[90m";

    /// Sets the foreground text color to bright red.
    pub const bright_red = "\x1b[91m";

    /// Sets the foreground text color to bright green.
    pub const bright_green = "\x1b[92m";

    /// Sets the foreground text color to bright yellow.
    pub const bright_yellow = "\x1b[93m";

    /// Sets the foreground text color to bright blue.
    pub const bright_blue = "\x1b[94m";

    /// Sets the foreground text color to bright magenta.
    pub const bright_magenta = "\x1b[95m";

    /// Sets the foreground text color to bright cyan.
    pub const bright_cyan = "\x1b[96m";

    /// Sets the foreground text color to bright white.
    pub const bright_white = "\x1b[97m";

    // ─────────────────────────────────────────
    // Standard background colors
    // ─────────────────────────────────────────

    /// Sets the terminal background color to black.
    pub const bg_black = "\x1b[40m";

    /// Sets the terminal background color to red.
    pub const bg_red = "\x1b[41m";

    /// Sets the terminal background color to green.
    pub const bg_green = "\x1b[42m";

    /// Sets the terminal background color to yellow.
    pub const bg_yellow = "\x1b[43m";

    /// Sets the terminal background color to blue.
    pub const bg_blue = "\x1b[44m";

    /// Sets the terminal background color to magenta.
    pub const bg_magenta = "\x1b[45m";

    /// Sets the terminal background color to cyan.
    pub const bg_cyan = "\x1b[46m";

    /// Sets the terminal background color to white.
    pub const bg_white = "\x1b[47m";

    // ─────────────────────────────────────────
    // Bright background colors
    // ─────────────────────────────────────────

    /// Sets the background color to bright black (gray).
    pub const bg_bright_black = "\x1b[100m";

    /// Sets the background color to bright red.
    pub const bg_bright_red = "\x1b[101m";

    /// Sets the background color to bright green.
    pub const bg_bright_green = "\x1b[102m";

    /// Sets the background color to bright yellow.
    pub const bg_bright_yellow = "\x1b[103m";

    /// Sets the background color to bright blue.
    pub const bg_bright_blue = "\x1b[104m";

    /// Sets the background color to bright magenta.
    pub const bg_bright_magenta = "\x1b[105m";

    /// Sets the background color to bright cyan.
    pub const bg_bright_cyan = "\x1b[106m";

    /// Sets the background color to bright white.
    pub const bg_bright_white = "\x1b[107m";

    // ─────────────────────────────────────────
    // Extended RGB foreground colors
    // ─────────────────────────────────────────

    /// Sets the foreground color to orange using 24-bit RGB.
    pub const orange = "\x1b[38;2;255;165;0m";

    /// Sets the foreground color to purple using 24-bit RGB.
    pub const purple = "\x1b[38;2;128;0;128m";

    /// Sets the foreground color to pink using 24-bit RGB.
    pub const pink = "\x1b[38;2;255;105;180m";

    /// Sets the foreground color to lime green using 24-bit RGB.
    pub const lime = "\x1b[38;2;50;205;50m";

    /// Sets the foreground color to gold using 24-bit RGB.
    pub const gold = "\x1b[38;2;255;215;0m";

    // ─────────────────────────────────────────
    // Text styles
    // ─────────────────────────────────────────

    /// Makes text bold or increases its intensity.
    pub const bold = "\x1b[1m";

    /// Makes text appear dimmer, if supported by the terminal.
    pub const dim = "\x1b[2m";

    /// Makes text italic, if supported by the terminal.
    pub const italic = "\x1b[3m";

    /// Underlines the text.
    pub const underline = "\x1b[4m";

    /// Enables blinking text, if supported by the terminal.
    pub const blink = "\x1b[5m";

    /// Reverses foreground and background colors.
    pub const reverse = "\x1b[7m";

    /// Hides text, if supported by the terminal.
    pub const hidden = "\x1b[8m";

    /// Adds a strikethrough effect to text.
    pub const strikethrough = "\x1b[9m";

    // ─────────────────────────────────────────
    // Reset codes
    // ─────────────────────────────────────────

    /// Resets all ANSI text styles and colors to their defaults.
    pub const reset = "\x1b[0m";

    /// Resets only the foreground color to the terminal default.
    pub const default_color = "\x1b[39m";

    /// Resets only the background color to the terminal default.
    pub const default_background = "\x1b[49m";

    // ─────────────────────────────────────────
    // Individual style reset codes
    // ─────────────────────────────────────────

    /// Disables bold and dim intensity.
    pub const normal_intensity = "\x1b[22m";

    /// Disables italic formatting.
    pub const no_italic = "\x1b[23m";

    /// Disables underline formatting.
    pub const no_underline = "\x1b[24m";

    /// Disables blinking text.
    pub const no_blink = "\x1b[25m";

    /// Disables reversed foreground and background colors.
    pub const no_reverse = "\x1b[27m";

    /// Disables hidden text formatting.
    pub const no_hidden = "\x1b[28m";

    /// Disables strikethrough formatting.
    pub const no_strikethrough = "\x1b[29m";
};

/// Commonly used combinations of ANSI text styles and colors.
///
/// Use these presets to avoid repeatedly concatenating ANSI escape codes.
pub const TextStyle = struct {
    /// Underline + bold + italic.
    pub const all_style =
        ColorAscii.underline ++
        ColorAscii.bold ++
        ColorAscii.italic;

    /// Bold + italic.
    pub const bold_italic =
        ColorAscii.bold ++
        ColorAscii.italic;

    /// Bold + underline.
    pub const bold_underline =
        ColorAscii.bold ++
        ColorAscii.underline;

    /// Italic + underline.
    pub const italic_underline =
        ColorAscii.italic ++
        ColorAscii.underline;

    /// Bold + italic + underline + bright cyan foreground.
    pub const highlighted =
        ColorAscii.bold ++
        ColorAscii.italic ++
        ColorAscii.underline ++
        ColorAscii.bright_cyan;

    /// Bold orange text.
    pub const warning =
        ColorAscii.bold ++
        ColorAscii.orange;

    /// Bold bright green text.
    pub const success =
        ColorAscii.bold ++
        ColorAscii.bright_green;

    /// Bold red text.
    pub const error_msg =
        ColorAscii.bold ++
        ColorAscii.red;
};
