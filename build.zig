const std = @import("std");
const Builder = std.build.Builder;
const builtin = @import("builtin");

const str = []const u8;
const strbuf = std.ArrayList(u8);
const alloc = std.testing.allocator;

pub fn build(b: *Builder) !void {

    const mode = b.standardReleaseOptions();

    const local = b.addExecutable("focus", "./src/root.zig");
    includeCommon(local);
    local.setBuildMode(mode);
    local.install();

    const cross = b.addExecutable("focus-cross", "./src/root.zig");
    includeCommon(cross);
    cross.setBuildMode(mode);
    cross.setTarget(
        std.zig.CrossTarget{
            .cpu_arch = .aarch64,
            .os_tag = .linux,
            .abi = .gnu,
        }
    );
    cross.install();

    const local_step = b.step("local", "Build for local");
    local_step.dependOn(&local.step);

    const cross_step = b.step("cross", "Build for focus");
    cross_step.dependOn(&cross.step);

    const run = local.run();
    const run_step = b.step("run", "Run locally");
    run_step.dependOn(&run.step);
}

fn includeCommon(exe: *std.build.LibExeObjStep) void {
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("GL");
    exe.linkSystemLibrary("SDL2");
    exe.setOutputDir("zig-cache");
}