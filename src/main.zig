usingnamespace @import("common.zig");

const draw = @import("./draw.zig");
const Fui = @import("./fui.zig").Fui;
const Memory = @import("./memory.zig").Memory;

const root_allocator = std.heap.c_allocator;

pub fn main() anyerror!void {
    draw.init();
    var fui = try Fui.init(root_allocator);
    defer fui.deinit();

    var arena = std.heap.ArenaAllocator.init(root_allocator);
    defer arena.deinit();

    var memory = try Memory.init(&arena);

    while (true) {
        while (!fui.handle_input()) {
            std.time.sleep(@divTrunc(std.time.second, 240));
        }
        try fui.begin();
        try memory.frame(&fui);
        try fui.end();
    }
}
