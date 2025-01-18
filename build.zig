const builtin = @import("builtin");
const std = @import("std");
const allocator = std.testing.allocator;
const freetype = @import("mach_freetype");
const glfw = @import("mach_glfw");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const config = b.addOptions();
    config.addOption(
        []const u8,
        "home_path",
        b.option([]const u8, "home-path", "") orelse "/home/jvf/dev/focus/",
    );
    config.addOption(
        []const u8,
        "projects_file_path",
        b.option([]const u8, "projects-file-path", "") orelse "/home/jvf/dev/focus/projects.txt",
    );

    const exe = b.addExecutable(.{
        .name = "focus-dev",
        .root_source_file = b.path("./src/focus.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
        .@"enable-libpng" = false,
    });
    exe.root_module.addImport("freetype", freetype_dep.module("freetype"));
    exe.linkLibrary(freetype_dep.artifact("freetype"));

    if (target.result.os.tag == .linux) {
        exe.linkSystemLibrary("GL");
        return error.LinuxNotSupported;
    } else if (target.result.os.tag == .windows) {
        exe.linkSystemLibrary("opengl32");
    } else if (target.result.os.tag == .macos) {
        exe.linkSystemLibrary("OpenGL");
        return error.MacosNotSupported;
    }

    const mach_glfw_dep = b.dependency("mach_glfw", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("glfw", mach_glfw_dep.module("mach-glfw"));

    b.installArtifact(exe);

    const exe_step = b.step("build", "Build");
    exe_step.dependOn(&exe.step);

    const run = b.addRunArtifact(exe);
    if (b.args) |args| {
        run.addArgs(args);
    }

    const run_step = b.step("run", "Run");
    run_step.dependOn(&run.step);
}
