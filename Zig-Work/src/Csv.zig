const std = @import("std");
const Writer = std.Io.Writer;

pub fn writeField(w: *Writer, field: []const u8) Writer.Error!void {
    var needs_quotes = false;

    for (field) |c| {
        if (c == ',' or c == '"' or c == '\n' or c == '\r') {
            needs_quotes = true;
            break;
        }
    }

    if (!needs_quotes) return w.writeAll(field);

    try w.writeByte('"');
    for (field) |c| {
        if (c == '"') try w.writeByte('"');
        try w.writeByte(c);
    }
    try w.writeByte('"');
}

pub fn writeRow(w: *Writer, fields: []const []const u8) Writer.Error!void {
    for (fields, 0..) |f, i| {
        if (i != 0) try w.writeByte(',');
        try writeField(w, f);
    }
    try w.writeAll("\r\n");
}

test "csv escaping" {
    var buf: [128]u8 = undefined;
    var w: Writer = .fixed(&buf);
    try writeRow(&w, &.{ "name", "say \"hi\"", "a,b" });
    try std.testing.expectEqualStrings("name,\"say \"\"hi\"\"\",\"a,b\"\r\n", w.buffered());
}


test "newline in field is quoted" {
    var buf: [64]u8 = undefined;
    var w: std.Io.Writer = .fixed(&buf);
    try writeRow(&w, &.{ "a\nb", "c" });
    try std.testing.expectEqualStrings("\"a\nb\",c\r\n", w.buffered());
}