const std = @import("std");
const printf = std.debug.warn;

const testing = std.testing;

const getType = ecs.getType;
const ecs = @import("ecs.zig");
const math = @import("math.zig");

const Renderer = @import("renderer.zig").Renderer;

extern fn keyCallback(window: ?*gfx.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void {
    printf("Press from key: {}\n", key);
}

pub fn main() anyerror!void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    var timer = std.time.Timer.start() catch unreachable;

    var renderer = try Renderer.init(&alloc.allocator);
    defer renderer.deinit();

    var cont = true;
    while (cont) {
        const delta = @intToFloat(f64, timer.lap()) / 1000 / 1000 / 1000;
        cont = renderer.update(delta);
    }
}
