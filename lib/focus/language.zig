const std = @import("std");
const focus = @import("../focus.zig");
const u = focus.util;
const c = focus.util.c;
const style = focus.style;
const imp2 = @import("../../imp2/lib/imp.zig");

pub const Language = enum {
    Zig,
    Java,
    Shell,
    Julia,
    Javascript,
    Imp2,
    Nix,
    Clojure,
    Unknown,

    pub fn fromFilename(filename: []const u8) Language {
        // TODO writing this as `return if ...` causes a confusing compiler error
        if (std.mem.endsWith(u8, filename, ".zig"))
            return .Zig
        else if (std.mem.endsWith(u8, filename, ".java"))
            return .Java
        else if (std.mem.endsWith(u8, filename, ".sh"))
            return .Shell
        else if (std.mem.endsWith(u8, filename, ".jl"))
            return .Julia
        else if (std.mem.endsWith(u8, filename, ".js"))
            return .Javascript
        else if (std.mem.endsWith(u8, filename, ".imp2"))
            return .Imp2
        else if (std.mem.endsWith(u8, filename, ".nix"))
            return .Nix
        else if (std.mem.endsWith(u8, filename, ".clj") or std.mem.endsWith(u8, filename, ".cljs") or std.mem.endsWith(u8, filename, ".cljc"))
            return .Clojure
        else
            return .Unknown;
    }

    pub fn commentString(self: Language) ?[]const u8 {
        return switch (self) {
            .Zig, .Java, .Javascript, .Imp2 => "//",
            .Shell, .Julia, .Nix => "#",
            .Clojure => ";",
            .Unknown => null,
        };
    }

    pub fn highlight(self: Language, allocator: u.Allocator, source: []const u8, range: [2]usize) []const u.Color {
        var extended_range = range;
        while (extended_range[0] > 0 and source[extended_range[0]] != '\n') extended_range[0] -= 1;
        while (extended_range[1] < source.len and source[extended_range[1]] != '\n') extended_range[1] += 1;
        const colors = allocator.alloc(u.Color, extended_range[1] - extended_range[0]) catch u.oom();
        switch (self) {
            .Zig => {
                const source_z = allocator.dupeZ(u8, source[extended_range[0]..extended_range[1]]) catch u.oom();
                defer allocator.free(source_z);
                var tokenizer = std.zig.Tokenizer.init(source_z);
                std.mem.set(u.Color, colors, style.comment_color);
                while (true) {
                    var token = tokenizer.next();
                    switch (token.tag) {
                        .eof => break,
                        .doc_comment, .container_doc_comment => {},
                        .identifier, .builtin, .integer_literal, .float_literal => std.mem.set(
                            u.Color,
                            colors[token.loc.start..token.loc.end],
                            style.identColor(tokenizer.buffer[token.loc.start..token.loc.end]),
                        ),
                        .keyword_try, .keyword_catch => std.mem.set(
                            u.Color,
                            colors[token.loc.start..token.loc.end],
                            style.emphasisRed,
                        ),
                        .keyword_defer, .keyword_errdefer => std.mem.set(
                            u.Color,
                            colors[token.loc.start..token.loc.end],
                            style.emphasisOrange,
                        ),
                        .keyword_break, .keyword_continue, .keyword_return => std.mem.set(
                            u.Color,
                            colors[token.loc.start..token.loc.end],
                            style.emphasisGreen,
                        ),
                        else => std.mem.set(
                            u.Color,
                            colors[token.loc.start..token.loc.end],
                            style.keyword_color,
                        ),
                    }
                }
            },
            .Imp2 => {
                var arena = u.ArenaAllocator.init(allocator);
                defer arena.deinit();
                var error_info: ?imp2.lang.pass.parse.ErrorInfo = null;
                var parser = imp2.lang.pass.parse.Parser{
                    .arena = &arena,
                    .source = source[extended_range[0]..extended_range[1]],
                    .exprs = u.ArrayList(imp2.lang.repr.syntax.Expr).init(arena.allocator()),
                    .from_source = u.ArrayList([2]usize).init(arena.allocator()),
                    .position = 0,
                    .error_info = &error_info,
                };
                std.mem.set(u.Color, colors, style.comment_color);
                while (true) {
                    const start = parser.position;
                    if (parser.nextTokenMaybe()) |maybe_token| {
                        if (maybe_token) |token| {
                            switch (token) {
                                .EOF => break,
                                .Number, .Text, .Name => std.mem.set(
                                    u.Color,
                                    colors[start..parser.position],
                                    style.identColor(parser.source[start..parser.position]),
                                ),
                                else => std.mem.set(
                                    u.Color,
                                    colors[start..parser.position],
                                    style.keyword_color,
                                ),
                            }
                        }
                    } else |err| {
                        if (err == error.OutOfMemory) u.oom();
                        parser.position += 1;
                    }
                }
            },
            else => {
                std.mem.set(u.Color, colors, style.text_color);
            },
        }
        return colors[range[0] - extended_range[0] ..];
    }
};
