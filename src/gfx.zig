// This file will have bgfx/glfw abstractions
// For the renderer, see renderer.zig

const std = @import("std");

pub usingnamespace @cImport({
    @cInclude("bgfx/c99/bgfx.h");

    @cInclude("wayland-client.h");
    @cInclude("wayland-egl.h");

    // GLFW shouldn't include any GL
    @cDefine("GLFW_INCLUDE_NONE", "");
    @cDefine("GLFW_EXPOSE_NATIVE_X11", "");

    @cInclude("GLFW/glfw3.h");
    @cInclude("GLFW/glfw3native.h");
});
