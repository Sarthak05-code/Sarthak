const std = @import("std");

// ============ TOKEN TYPES ============

pub const TokenType = enum {
    // Literals
    identifier,
    number,
    string,

    // Keywords
    kw_fn,
    kw_var,
    kw_const,
    kw_if,
    kw_else,
    kw_while,
    kw_return,
    kw_true,
    kw_false,

    // Operators
    plus,
    minus,
    star,
    slash,
    assign,
    equal,
    not_equal,
    less,
    greater,
    less_equal,
    greater_equal,
    bang,
    and_op,
    or_op,

    // Delimiters
    l_paren,
    r_paren,
    l_brace,
    r_brace,
    l_bracket,
    r_bracket,
    semicolon,
    colon,
    comma,
    dot,
    arrow, // =>

    // Special
    eof,
    illegal,
};

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
    line: usize,
    column: usize,

    pub fn format(
        self: Token,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print(
            "Token{{ .{s}, \"{s}\", line {}, col {} }}",
            .{ @tagName(self.type), self.literal, self.line, self.column },
        );
    }
};

// ============ LEXER ============

pub const Lexer = struct {
    input: []const u8,
    pos: usize, // current position in input
    read_pos: usize, // next position to read
    ch: u8, // current character
    line: usize,
    column: usize,

    pub fn init(input: []const u8) Lexer {
        var l = Lexer{
            .input = input,
            .pos = 0,
            .read_pos = 0,
            .ch = 0,
            .line = 1,
            .column = 0,
        };
        l.readChar();
        return l;
    }

    fn readChar(self: *Lexer) void {
        if (self.read_pos >= self.input.len) {
            self.ch = 0; // EOF
        } else {
            self.ch = self.input[self.read_pos];
        }
        self.pos = self.read_pos;
        self.read_pos += 1;

        if (self.ch == '\n') {
            self.line += 1;
            self.column = 0;
        } else {
            self.column += 1;
        }
    }

    fn peekChar(self: *Lexer) u8 {
        if (self.read_pos >= self.input.len) {
            return 0;
        }
        return self.input[self.read_pos];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        const start = self.pos;
        while (isLetter(self.ch) or isDigit(self.ch) or self.ch == '_') {
            self.readChar();
        }
        return self.input[start..self.pos];
    }

    fn readNumber(self: *Lexer) []const u8 {
        const start = self.pos;
        while (isDigit(self.ch)) {
            self.readChar();
        }
        // Float support
        if (self.ch == '.' and isDigit(self.peekChar())) {
            self.readChar();
            while (isDigit(self.ch)) {
                self.readChar();
            }
        }
        return self.input[start..self.pos];
    }

    fn readString(self: *Lexer) ![]const u8 {
        const start_line = self.line;
        const start_col = self.column;
        _ = start_line;
        _ = start_col;

        self.readChar(); // consume opening quote
        const start = self.pos;

        while (self.ch != '"' and self.ch != 0) {
            if (self.ch == '\\') {
                self.readChar(); // skip escaped char
                if (self.ch != 0) self.readChar();
            } else {
                self.readChar();
            }
        }

        const str = self.input[start..self.pos];

        if (self.ch != '"') {
            return error.UnterminatedString;
        }
        self.readChar(); // consume closing quote

        return str;
    }

    fn lookupIdent(ident: []const u8) TokenType {
        const map = std.StaticStringMap(TokenType).initComptime(.{
            .{ "fn", .kw_fn },
            .{ "var", .kw_var },
            .{ "const", .kw_const },
            .{ "if", .kw_if },
            .{ "else", .kw_else },
            .{ "while", .kw_while },
            .{ "return", .kw_return },
            .{ "true", .kw_true },
            .{ "false", .kw_false },
        });
        return map.get(ident) orelse .identifier;
    }

    pub fn nextToken(self: *Lexer) !Token {
        self.skipWhitespace();

        const line = self.line;
        const col = self.column;

        const tok: Token = switch (self.ch) {
            0 => .{ .type = .eof, .literal = "", .line = line, .column = col },

            '+' => makeTok(self, .plus, "+", line, col),
            '-' => blk: {
                if (self.peekChar() == '>') {
                    self.readChar();
                    break :blk makeTok(self, .arrow, "=>", line, col);
                }
                break :blk makeTok(self, .minus, "-", line, col);
            },
            '*' => makeTok(self, .star, "*", line, col),
            '/' => makeTok(self, .slash, "/", line, col),

            '(' => makeTok(self, .l_paren, "(", line, col),
            ')' => makeTok(self, .r_paren, ")", line, col),
            '{' => makeTok(self, .l_brace, "{", line, col),
            '}' => makeTok(self, .r_brace, "}", line, col),
            '[' => makeTok(self, .l_bracket, "[", line, col),
            ']' => makeTok(self, .r_bracket, "]", line, col),
            ';' => makeTok(self, .semicolon, ";", line, col),
            ':' => makeTok(self, .colon, ":", line, col),
            ',' => makeTok(self, .comma, ",", line, col),
            '.' => makeTok(self, .dot, ".", line, col),

            '!' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk makeTok(self, .not_equal, "!=", line, col);
                }
                break :blk makeTok(self, .bang, "!", line, col);
            },
            '=' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk makeTok(self, .equal, "==", line, col);
                }
                if (self.peekChar() == '>') {
                    self.readChar();
                    break :blk makeTok(self, .arrow, "=>", line, col);
                }
                break :blk makeTok(self, .assign, "=", line, col);
            },
            '<' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk makeTok(self, .less_equal, "<=", line, col);
                }
                break :blk makeTok(self, .less, "<", line, col);
            },
            '>' => blk: {
                if (self.peekChar() == '=') {
                    self.readChar();
                    break :blk makeTok(self, .greater_equal, ">=", line, col);
                }
                break :blk makeTok(self, .greater, ">", line, col);
            },
            '&' => blk: {
                if (self.peekChar() == '&') {
                    self.readChar();
                    break :blk makeTok(self, .and_op, "&&", line, col);
                }
                break :blk makeTok(self, .illegal, "&", line, col);
            },
            '|' => blk: {
                if (self.peekChar() == '|') {
                    self.readChar();
                    break :blk makeTok(self, .or_op, "||", line, col);
                }
                break :blk makeTok(self, .illegal, "|", line, col);
            },

            '"' => .{
                .type = .string,
                .literal = try self.readString(),
                .line = line,
                .column = col,
            },

            else => blk: {
                if (isLetter(self.ch)) {
                    const ident = self.readIdentifier();
                    break :blk .{
                        .type = lookupIdent(ident),
                        .literal = ident,
                        .line = line,
                        .column = col,
                    };
                } else if (isDigit(self.ch)) {
                    const num = self.readNumber();
                    break :blk .{
                        .type = .number,
                        .literal = num,
                        .line = line,
                        .column = col,
                    };
                } else {
                    const ch = self.ch;
                    _ = ch;
                    self.readChar();
                    break :blk .{
                        .type = .illegal,
                        .literal = self.input[self.pos - 1 .. self.pos],
                        .line = line,
                        .column = col,
                    };
                }
            },
        };

        // readChar already advanced for single-char tokens, but for identifiers
        // and numbers readChar advanced past them. For single-char tokens we
        // need to advance here.
        switch (tok.type) {
            .identifier, .number, .string, .eof => {}, // already advanced
            else => {
                // For operators and delimiters, we need to advance if not already
                // Actually readChar is called in makeTok, so we're good
            },
        }

        return tok;
    }

    fn makeTok(self: *Lexer, ttype: TokenType, lit: []const u8, line: usize, col: usize) Token {
        self.readChar();
        return .{
            .type = ttype,
            .literal = lit,
            .line = line,
            .column = col,
        };
    }
};

// ============ HELPERS ============

fn isLetter(ch: u8) bool {
    return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or ch == '_';
}

fn isDigit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}

// ============ MAIN / DEMO ============

pub fn main() !void {
    const source =
        \\fn add(x: i32, y: i32) => i32 {
        \\    return x + y;
        \\}
        \\
        \\var name = "Sarthak Thapa";
        \\const PI = 3.14159;
        \\
        \\if (x >= 10 && y != 20) {
        \\    while (true) {
        \\        do_something();
        \\    }
        \\} else {
        \\    return false;
        \\}
    ;

    var gpa_state: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa_state.allocator();
    defer _ = gpa_state.deinit();

    std.debug.print("=== Source ===\n{s}\n\n", .{source});
    std.debug.print("=== Tokens ===\n", .{});

    var lexer = Lexer.init(source);

    while (true) {
        const tok = try lexer.nextToken();
        std.debug.print("{}\n", .{tok});

        if (tok.type == .eof) break;
    }

    // Collect tokens into a list
    std.debug.print("\n=== Collected Token List ===\n", .{});

    var tokens: std.ArrayList(Token) = .empty;
    defer tokens.deinit(allocator);

    var lexer2 = Lexer.init(source);
    while (true) {
        const tok = try lexer2.nextToken();
        try tokens.append(allocator, tok);
        if (tok.type == .eof) break;
    }

    std.debug.print("Total tokens: {}\n", .{tokens.items.len});
    for (tokens.items) |t| {
        std.debug.print("{s} ", .{@tagName(t.type)});
    }
    std.debug.print("\n", .{});
}
