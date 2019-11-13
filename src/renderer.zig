const std = @import("std");

const ecs = @import("ecs.zig");

use @import("gfx.zig");

pub const Renderer = struct {
    alloc: *std.mem.Allocator,

    window: *GLFWwindow,

    cameras: *ecs.View,
    renderables: *ecs.View,

    shaders: std.ArrayList(bgfx_shader_handle_t),
    programs: std.ArrayList(bgfx_program_handle_t),
    uniforms: std.ArrayList(bgfx_uniform_handle_t),
    vbuffs: std.ArrayList(bgfx_vertex_buffer_handle_t),
    dyn_vbuffs: std.ArrayList(bgfx_dynamic_vertex_buffer_handle_t),
    ibuffs: std.ArrayList(bgfx_index_buffer_handle_t),
    dyn_ibuffs: std.ArrayList(bgfx_dynamic_index_buffer_handle_t),
    textures: std.ArrayList(bgfx_texture_handle_t),

    framebuffers: std.ArrayList(bgfx_frame_buffer_handle_t),

    extern fn errorCallback(err: c_int, description: [*c]const u8) void {
        // TODO: Fix this bug in zig's src
        const desc: [*]const u8 = description;
        printf("Got errorcode {}: `{s}`\n", err, desc);
    }
    pub fn init(alloc: *std.mem.Allocator) Renderer {
      _ = glfwSetErrorCallback(errorCallback);

      if (glfwInit() != GLFW_TRUE)
          return error.GLFWInitFailed;
      defer glfwTerminate();

      if (glfwVulkanSupported() != GLFW_TRUE)
          return error.VulkanNotSupported;

      // TODO: A small wrapper around some of the less desirable GLFW stuff
      glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
      glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);

      var width: c_int = 1600;
      var height: c_int = 900;

      var window = glfwCreateWindow(width, height, c"sway:floater", null, null);
      defer glfwDestroyWindow(window);

      var platform_data = bgfx_platform_data_t{
          // TODO: Make this all work with wayland.
          //.ndt = glfwGetWaylandDisplay(),
          .ndt      = glfwGetX11Display(),
          .nwh = @intToPtr(*c_void, glfwGetX11Window(window)),
          .context = null,
          .backBuffer = null,
          .backBufferDS = null,
      };
      _ = bgfx_set_platform_data(&platform_data);
      var init_params = bgfx_init_t{
          .@"type" = BGFX_RENDERER_TYPE_VULKAN,
          .vendorId = 0, // BGFX_PCI_ID_NONE,
          .deviceId = 0, // First
          .debug = false,
          .profile = false,
          .platformData = platform_data,
          .resolution = bgfx_resolution_t{
              .format = BGFX_TEXTURE_FORMAT_RGBA16,
              .width = 1600,
              .height = 900,
              .reset = 0, // BGFX_RESET_NONE
              .numBackBuffers = 1,
              .maxFrameLatency = 1, // TODO
          },
          .limits = bgfx_init_limits_t{
              .maxEncoders = 4,
              .transientVbSize = 6 << 20, // From bgfx's config.h
              .transientIbSize = 2 << 20,
          },
          .callback = null,
          .allocator = null,
      };
      _ = bgfx_init(&init_params);
      // Done in this.deinit
      //defer bgfx_shutdown();
      // TODO: Make a full-on BGFX wrapper.
      bgfx_set_debug(8);

      // Clear Color | Depth | Stencil
      bgfx_set_view_clear(0, 1 | 2 | 4, 0x303030ff, 1.0, 0);

        return Renderer {
            .alloc = alloc,
            .window = window,
            .cameras = World.allWith([_]type{Camera}),
            .renderables = World.allWith([_]type{Mesh}),
            // TODO:
            // .lights = world.allWith([_]type{Light}),

            .shaders = std.ArrayList(bgfx_shader_handle_t).init(alloc),
            .programs = std.ArrayList(bgfx_program_handle_t).init(alloc),
            .uniforms = std.ArrayList(bgfx_uniform_handle_t).init(alloc),
            .vbuffs = std.ArrayList(bgfx_vertex_buffer_handle_t).init(alloc),
            .dyn_vbuffs = std.ArrayList(bgfx_dynamic_vertex_buffer_handle_t).init(alloc),
            .ibuffs = std.ArrayList(bgfx_index_buffer_handle_t).init(alloc),
            .dyn_ibuffs = std.ArrayList(bgfx_dynamic_index_buffer_handle_t).init(alloc),
            .textures = std.ArrayList(bgfx_texture_handle_t).init(alloc),

            .framebuffers = std.ArrayList(bgfx_frame_buffer_handle_t).init(alloc),
        };
    }

    pub fn deinit(self: *Renderer) void {
        bgfx_shutdown();
    }

    pub const KeyCallback = extern fn(window: ?*gfx.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void;
    pub fn setKeyCallback(callback: KeyCallback) void {
        glfwSetKeyCallback(window, callback);
    }

    pub fn update(self: *Renderer, delta: f64) bool {
        glfwPollEvents();
        glfwGetWindowSize(window, &width, &height);
        //printf("Current size: {}, {}\n", width, height);
        bgfx_set_view_rect(0, 0, 0, @intCast(u16, width), @intCast(u16, height));
        bgfx_touch(0);

        // The 2 spaces are needed otherwise it somehow has a ghost at the end of the line
        bgfx_dbg_text_printf(0,0,0x0f, c"FPS: %.0f  ", 1.0 / (@intToFloat(f64, timer.lap()) / 1000 / 1000 / 1000));
        
        _ = bgfx_frame(false);

        std.time.sleep(16 * 1000 * 1000);
    
        // If it ain't true we can continue our merry way
        return glfwWindowShouldClose(window) != GLFW_TRUE;
    }

};
