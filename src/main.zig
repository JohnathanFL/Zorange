const std = @import("std");
const printf = std.debug.warn;

const testing = std.testing;

const getType = ecs.getType;
usingnamespace @import("ecs.zig");
usingnamespace @import("math.zig");

const gfx = @import("gfx.zig");

const Name = struct {
    pub const storage = VecStorage(Name, std.heap.c_allocator);
    name: []const u8,
};

const Hair = enum {
    pub const storage = VecStorage(Hair, std.heap.c_allocator);
    Bald,
    Normal,
    ShitTon,
};

extern fn errorCallback(err: c_int, description: [*c]const u8) void {
    // TODO: Fix this bug in zig's src
    const desc: [*]const u8 = description;
    printf("Got errorcode {}: `{s}`\n", err, desc);
}

extern fn keyCallback(window: ?*gfx.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void {
    printf("Press from key: {}\n", key);
}

pub fn main() anyerror!void {
    _ = gfx.glfwSetErrorCallback(errorCallback);

    if (gfx.glfwInit() != gfx.GLFW_TRUE)
        return error.GLFWInitFailed;
    defer gfx.glfwTerminate();

    if (gfx.glfwVulkanSupported() != gfx.GLFW_TRUE)
        return error.VulkanNotSupported;

    // TODO: A small wrapper around some of the less desirable GLFW stuff
    gfx.glfwWindowHint(gfx.GLFW_RESIZABLE, gfx.GLFW_FALSE);
    gfx.glfwWindowHint(gfx.GLFW_CLIENT_API, gfx.GLFW_NO_API);

    var width: c_int = 1600;
    var height: c_int = 900;

    var window = gfx.glfwCreateWindow(width, height, c"sway:floater", null, null);
    defer gfx.glfwDestroyWindow(window);

    var platform_data = gfx.bgfx_platform_data_t{
        // TODO: Make this all work with wayland.
        //.ndt = gfx.glfwGetWaylandDisplay(),
        .ndt      = gfx.glfwGetX11Display(),
        .nwh = @intToPtr(*c_void, gfx.glfwGetX11Window(window)),
        .context = null,
        .backBuffer = null,
        .backBufferDS = null,
    };
    _ = gfx.bgfx_set_platform_data(&platform_data);
    var init_params = gfx.bgfx_init_t{
        .@"type" = gfx.BGFX_RENDERER_TYPE_VULKAN,
        .vendorId = 0, // gfx.BGFX_PCI_ID_NONE,
        .deviceId = 0, // First
        .debug = false,
        .profile = false,
        .platformData = platform_data,
        .resolution = gfx.bgfx_resolution_t{
            .format = gfx.BGFX_TEXTURE_FORMAT_RGBA16,
            .width = 1600,
            .height = 900,
            .reset = 0, // BGFX_RESET_NONE
            .numBackBuffers = 1,
            .maxFrameLatency = 1, // TODO
        },
        .limits = gfx.bgfx_init_limits_t{
            .maxEncoders = 4,
            .transientVbSize = 6 << 20, // From bgfx's config.h
            .transientIbSize = 2 << 20,
        },
        .callback = null,
        .allocator = null,
    };
    _ = gfx.bgfx_init(&init_params);
    defer gfx.bgfx_shutdown();
    // TODO: Make a full-on BGFX wrapper.
    gfx.bgfx_set_debug(8);

    // Clear Color | Depth | Stencil
    gfx.bgfx_set_view_clear(0, 1 | 2 | 4, 0x303030ff, 1.0, 0);

    _ = gfx.glfwSetKeyCallback(window, keyCallback);

    var timer = std.time.Timer.start() catch unreachable;
    while (gfx.glfwWindowShouldClose(window) == gfx.GLFW_FALSE) {
        gfx.glfwPollEvents();
        gfx.glfwGetWindowSize(window, &width, &height);
        //printf("Current size: {}, {}\n", width, height);
        gfx.bgfx_set_view_rect(0, 0, 0, @intCast(u16, width), @intCast(u16, height));
        gfx.bgfx_touch(0);

        // The 2 spaces are needed otherwise it somehow has a ghost at the end of the line
        gfx.bgfx_dbg_text_printf(0,0,0x0f, c"FPS: %.0f  ", 1.0 / (@intToFloat(f64, timer.lap()) / 1000 / 1000 / 1000));
        
        _ = gfx.bgfx_frame(false);

        std.time.sleep(16 * 1000 * 1000);
    }
}
