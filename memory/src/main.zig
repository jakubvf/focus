usingnamespace @import("common.zig");
const Plumbing = @import("plumbing.zig").Plumbing;

pub const screen_height = 1440;
pub const screen_width = 720;

pub fn main() anyerror!void {
    const Op = enum { Easy, Hard };
    var op: Op = .Easy;
    var property: c_int = 20;

    var plumbing = Plumbing.init(screen_height, screen_width);
    defer plumbing.deinit();

    var is_running = true;
    while (is_running) {
        plumbing.handle_input(&is_running);

        var ctx = &plumbing.nk.ctx;
        if (nk_true == nk_begin(ctx, "Demo", nk_rect(0, 0, screen_width, screen_height), 0)) {
            nk_menubar_begin(ctx);
            nk_layout_row_begin(ctx, .NK_STATIC, 25, 2);
            nk_layout_row_push(ctx, 45);
            if (nk_true == nk_menu_begin_label(ctx, "FILE", NK_TEXT_LEFT, nk_vec2(120, 200))) {
                nk_layout_row_dynamic(ctx, 30, 1);
                _ = nk_menu_item_label(ctx, "OPEN", NK_TEXT_LEFT);
                _ = nk_menu_item_label(ctx, "CLOSE", NK_TEXT_LEFT);
                nk_menu_end(ctx);
            }
            nk_layout_row_push(ctx, 45);
            if (nk_true == nk_menu_begin_label(ctx, "EDIT", NK_TEXT_LEFT, nk_vec2(120, 200))) {
                nk_layout_row_dynamic(ctx, 30, 1);
                _ = nk_menu_item_label(ctx, "COPY", NK_TEXT_LEFT);
                _ = nk_menu_item_label(ctx, "CUT", NK_TEXT_LEFT);
                _ = nk_menu_item_label(ctx, "PASTE", NK_TEXT_LEFT);
                nk_menu_end(ctx);
            }
            nk_layout_row_end(ctx);
            nk_menubar_end(ctx);

            nk_layout_row_static(ctx, 30, 80, 1);
            if (nk_true == nk_button_label(ctx, "button"))
                _ = fprintf(stdout, "button pressed\n");
            nk_layout_row_dynamic(ctx, 30, 2);
            if (nk_true == nk_option_label(ctx, "easy", nk_bool(op == .Easy))) op = .Easy;
            if (nk_true == nk_option_label(ctx, "hard", nk_bool(op == .Hard))) op = .Hard;
            nk_layout_row_dynamic(ctx, 25, 1);
            nk_property_int(ctx, "Compression:", 0, &property, 100, 10, 1);
        }
        nk_end(ctx);

        plumbing.draw(0.55);
    }

    warn("fin\n", .{});
}

fn nk_bool(b: bool) c_int {
    return if (b) nk_true else nk_false;
}
