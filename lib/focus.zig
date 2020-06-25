pub const common = @import("./focus/common.zig");
pub const meta = @import("./focus/meta.zig");
pub const atlas = @import("./focus/atlas.zig");
pub const draw = @import("./focus/draw.zig");
pub const UI = @import("./focus/ui.zig").UI;
pub const Memory = @import("./focus/memory.zig").Memory;
pub const Editor = @import("./focus/editor.zig").Editor;

usingnamespace common;

pub fn run(allocator: *Allocator) !void {
    draw.init();
    var ui = UI.init(allocator);
    defer ui.deinit();

    // var memory = try Memory.init(allocator);
    // defer memory.deinit();

    var editor = try Editor.init(allocator, "some initial text\nand some more\nshort\nreaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaally long");

    while (true) {
        _ = try ui.handleInput();
        const screen = try ui.begin();
        // try memory.frame(&ui, screen);
        try editor.frame(&ui, screen);
        try ui.end();
    }
}
