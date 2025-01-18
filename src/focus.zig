const builtin = @import("builtin");
const std = @import("std");

const focus = @import("lib/focus.zig");

pub var gpa = if (builtin.mode == .Debug)
    std.heap.GeneralPurposeAllocator(.{
        .never_unmap = false,
    }){}
else
    null;

const Action = union(enum) {
    Angel,
    Request: focus.Request,
};

pub fn main() void {
    const allocator = if (builtin.mode == .Debug) gpa.allocator() else std.heap.c_allocator;
    var arena = focus.util.ArenaAllocator.init(allocator);

    const args = std.process.argsAlloc(arena.allocator()) catch focus.util.oom();
    _ = args;

    std.debug.print("bruh\n", .{});
    focus.run(allocator);
}
