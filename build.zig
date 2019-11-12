const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = builtin.Mode.Debug;
    var lib = b.addExecutable("Zorange", "src/main.zig");
    lib.setBuildMode(mode);
    b.addNativeSystemIncludeDir("/usr/include");
    b.addNativeSystemIncludeDir("/usr/local/include");

    lib.linkSystemLibrary("c");
    lib.linkSystemLibrary("dl");
    lib.linkSystemLibrary("x11");
    lib.linkSystemLibrary("wayland-client");
    lib.linkSystemLibrary("wayland-egl");
    lib.linkSystemLibrary("stdc++");
    lib.linkSystemLibrary("glfw");
    lib.linkSystemLibrary("gl");
    lib.linkSystemLibrary("glx");
    lib.linkSystemLibrary("vulkan");
    lib.linkSystemLibrary("bgfx");
    lib.linkSystemLibrary("bx");
    lib.linkSystemLibrary("bimg");

    lib.install();

    var main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const run_cmd = lib.run(); // TODO: Clean up the build file
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run app");
    run_step.dependOn(&run_cmd.step);
}
