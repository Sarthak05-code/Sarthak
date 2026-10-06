const std = @import("std");
const Allocator = std.mem.Allocator;

const ones = [_][]const u8{
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
};

const teens = [_][]const u8{
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
};

const tens = [_][]const u8{
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
};

const thousands = [_][]const u8{
    "",
    "Thousand",
    "Million",
    "Billion",
    "Trillion",
    "Quadrillion",
    "Quintillion",
};

fn helper(
    allocator: Allocator,
    n: u64,
    list: *std.ArrayList([]const u8),
) !void {
    if (n == 0) {
        return;
    } else if (n < 10) {
        try list.append(allocator, ones[n]);
    } else if (n < 20) {
        try list.append(allocator, teens[n - 10]);
    } else if (n < 100) {
        try list.append(allocator, tens[n / 10]);
        try helper(allocator, n % 10, list);
    } else {
        try list.append(allocator, ones[n / 100]);
        try list.append(allocator, "Hundred");
        try helper(allocator, n % 100, list);
    }
}

fn numberToWords(allocator: Allocator, num: u64) ![]const u8 {
    if (num == 0) {
        return try allocator.dupe(u8, "Zero");
    }

    var final_tokens: std.ArrayList([]const u8) = .empty;
    defer final_tokens.deinit(allocator);

    var temp_num = num;
    var chunk_index: usize = 0;

    while (temp_num > 0) : (chunk_index += 1) {
        const chunk = temp_num % 1000;

        if (chunk != 0) {
            var chunk_tokens: std.ArrayList([]const u8) = .empty;
            defer chunk_tokens.deinit(allocator);

            try helper(allocator, chunk, &chunk_tokens);

            if (chunk_index > 0) {
                try chunk_tokens.append(
                    allocator,
                    thousands[chunk_index],
                );
            }

            try final_tokens.insertSlice(
                allocator,
                0,
                chunk_tokens.items,
            );
        }

        temp_num /= 1000;
    }

    return try std.mem.join(
        allocator,
        " ",
        final_tokens.items,
    );
}

pub fn main() !void {
    var arena: std.heap.ArenaAllocator =
        .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const test_cases = [_]u64{ 1, 25, 456, 123456, 987654321, 123 };

    for (test_cases) |val| {
        const word_str = try numberToWords(
            allocator,
            val,
        );

        std.debug.print(
            "{d: <10} => {s}\n",
            .{ val, word_str },
        );
    }
}


