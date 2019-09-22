const std = @import("std");
const warn = std.debug.warn;
const assert = std.debug.assert;

pub use @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const Flagset = struct {
    pub raw: u32,

    pub fn new() Flagset {
        return Flagset{ .raw = 0 };
    }

    pub fn with(self: Flagset, val: u32) Flagset {
        return Flagset{ .raw = self.raw | val };
    }

    pub fn without(self: Flagset, val: u32) Flagset {
        return Flagset{ .raw = self.raw & (~val) };
    }

    pub fn asU32() u32 {
        return raw;
    }

    pub fn asCInt() c_int {
        return @intCast(c_int, raw);
    }
};

// Makes creating a new flagset a little easier
pub const Flags = Flagset.new();

pub const InitMode = struct {
    pub const Video = SDL_INIT_VIDEO;
    pub const Events = SDL_INIT_EVENTS;
    pub const Timer = SDL_INIT_TIMER;
    pub const Haptic = SDL_INIT_HAPTIC;
    pub const GameController = SDL_INIT_GAMECONTROLLER;
    pub const Joystick = SDL_INIT_JOYSTICK;
    pub const Everything = Video | Events | Timer | Haptic | GameController | Joystick;
};

pub fn init(flags: Flagset) !void {
    const res = SDL_Init(flags.raw);

    if (res == 0) {
        return;
    } else {
        return error.InitFailed;
    }
}

pub const quit = SDL_Quit;

pub const GLProfile = enum(u32) {
    Core = SDL_GL_CONTEXT_PROFILE_CORE,
    Compatability = SDL_GL_CONTEXT_PROFILE_COMPATIBILITY,
    ES = SDL_GL_CONTEXT_PROFILE_ES, // TODO

    pub fn asU32(self: GLProfile) u32 {
        return @enumToInt(self);
    }

    pub fn asCInt(self: GLProfile) c_int {
        return @intCast(c_int, self.asU32());
    }
};

pub const GLAttr = enum(c_int) {
    RedSize = SDL_GL_RED_SIZE,
    GreenSize = SDL_GL_GREEN_SIZE,
    BlueSize = SDL_GL_BLUE_SIZE,
    AlphaSize = SDL_GL_ALPHA_SIZE,
    BufferSize = SDL_GL_BUFFER_SIZE,
    DoubleBuffer = SDL_GL_DOUBLEBUFFER,
    DepthSize = SDL_GL_DEPTH_SIZE,
    StencilSize = SDL_GL_STENCIL_SIZE,
    AccumRedSize = SDL_GL_ACCUM_RED_SIZE,
    AccumGreenSize = SDL_GL_ACCUM_GREEN_SIZE,
    AccumBlueSize = SDL_GL_ACCUM_BLUE_SIZE,
    AccumAlphaSize = SDL_GL_ACCUM_ALPHA_SIZE,
    Stereo = SDL_GL_STEREO,
    MultisampleBuffers = SDL_GL_MULTISAMPLEBUFFERS,
    MultisampleSamples = SDL_GL_MULTISAMPLESAMPLES,
    AcceleratedVisual = SDL_GL_ACCELERATED_VISUAL,
    MajorVersion = SDL_GL_CONTEXT_MAJOR_VERSION,
    MinorVersion = SDL_GL_CONTEXT_MINOR_VERSION,
    ContextFlags = SDL_GL_CONTEXT_FLAGS,
    ProfileMask = SDL_GL_CONTEXT_PROFILE_MASK,
    ShareContext = SDL_GL_SHARE_WITH_CURRENT_CONTEXT,
    SRGBCapable = SDL_GL_FRAMEBUFFER_SRGB_CAPABLE,
    ReleaseBehavior = SDL_GL_CONTEXT_RELEASE_BEHAVIOR,

    pub fn get(attr: GLAttr) !c_int {
        var res: c_int = undefined;
        var ret = SDL_GL_GetAttribute(@enumToInt(attr), &res);
        if (ret == 0) {
            return res;
        } else {
            return error.FailedToGetGLAttr;
        }
    }

    pub fn set(attr: GLAttr, value: c_int) !void {
        var res = SDL_GL_SetAttribute(@intToEnum(SDL_GLattr, @enumToInt(attr)), value);
        if (res != 0) {
            return error.FailedToSetGLAttr;
        }
    }
};

pub const Window = struct {
    handle: *SDL_Window,

    pub const Fullscreen = SDL_WINDOW_FULLSCREEN;
    pub const FullscreenDesktop = SDL_WINDOW_FULLSCREEN_DESKTOP;
    pub const OpenGL = SDL_WINDOW_OPENGL;
    pub const Vulkan = SDL_WINDOW_VULKAN;
    pub const Hidden = SDL_WINDOW_HIDDEN;
    pub const Borderless = SDL_WINDOW_BORDERLESS;
    pub const Resizable = SDL_WINDOW_RESIZABLE;
    pub const Minimized = SDL_WINDOW_MINIMIZED;
    pub const Maximized = SDL_WINDOW_MAXIMIZED;
    pub const InputGrabbed = SDL_WINDOW_INPUT_GRABBED;
    pub const HighDPI = SDL_WINDOW_ALLOW_HIGHDPI;

    pub fn create(title: [*]const u8, x: i32, y: i32, width: i32, height: i32, flags: Flagset) !Window {
        var res = SDL_CreateWindow(title, x, y, width, height, flags.raw);

        if (res != null) {
            return Window{ .handle = @ptrCast(*SDL_Window, res) };
        } else {
            return error.WindowCreationFailed;
        }
    }

    pub fn destroy(self: Window) void {
        SDL_DestroyWindow(self.handle);
    }

    pub fn show(self: Window) void {
        SDL_ShowWindow(self.handle);
    }

    pub fn swapGL(self: Window) void {
        SDL_GL_SwapWindow(self.handle);
    }

    pub fn createGLContext(self: Window) !GLContext {
        var res = SDL_GL_CreateContext(self.handle);

        if (res == null) {
            return error.GLContextCreationFailed;
        } else {
            return GLContext{ .handle = res };
        }
    }
};

pub const GLContext = struct {
    handle: SDL_GLContext,

    pub fn destroy(self: GLContext) void {
        SDL_GL_DeleteContext(self.handle);
    }
};

pub const EventType = struct {
    pub const DeviceAdded: u32 = SDL_AUDIODEVICEADDED;
    pub const DeviceRemoved: u32 = SDL_AUDIODEVICEREMOVED;
    pub const ControllerMotion: u32 = SDL_CONTROLLERAXISMOTION;
    pub const ControllerBtnDown: u32 = SDL_CONTROLLERBUTTONDOWN;
    pub const ControllerBtnUp: u32 = SDL_CONTROLLERBUTTONUP;
    pub const ControllerAdded: u32 = SDL_CONTROLLERDEVICEADDED;
    pub const ControllerRemoved: u32 = SDL_CONTROLLERDEVICEREMOVED;
    pub const ControllerRemapped: u32 = SDL_CONTROLLERDEVICEREMAPPED;
    pub const DollarGesture: u32 = SDL_DOLLARGESTURE;
    pub const DollarRecord: u32 = SDL_DOLLARRECORD;
    pub const DropFile: u32 = SDL_DROPFILE;
    pub const DropText: u32 = SDL_DROPTEXT;
    pub const DropBegin: u32 = SDL_DROPBEGIN;
    pub const DropComplete: u32 = SDL_DROPCOMPLETE;
    pub const FingerMotion: u32 = SDL_FINGERMOTION;
    pub const FingerDown: u32 = SDL_FINGERDOWN;
    pub const FingerUp: u32 = SDL_FINGERUP;
    pub const KeyDown: u32 = SDL_KEYDOWN;
    pub const KeyUp: u32 = SDL_KEYUP;
    pub const JoyAxisMotion: u32 = SDL_JOYAXISMOTION;
    pub const JoyBallMotion: u32 = SDL_JOYBALLMOTION;
    pub const JoyHatMotion: u32 = SDL_JOYHATMOTION;
    pub const JoyBtnDown: u32 = SDL_JOYBUTTONDOWN;
    pub const JoyBtnUp: u32 = SDL_JOYBUTTONUP;
    pub const JoyAdded: u32 = SDL_JOYDEVICEADDED; // D
    pub const JoyRemoved: u32 = SDL_JOYDEVICEREMOVED; // (
    pub const MouseMotion: u32 = SDL_MOUSEMOTION;
    pub const MouseBtnDown: u32 = SDL_MOUSEBUTTONDOWN;
    pub const MouseBtnUp: u32 = SDL_MOUSEBUTTONUP;
    pub const MouseWheel: u32 = SDL_MOUSEWHEEL;
    pub const MultiGesture: u32 = SDL_MULTIGESTURE;
    pub const Quit: u32 = SDL_QUIT;
    pub const SysWM: u32 = SDL_SYSWMEVENT;
    pub const TextEditing: u32 = SDL_TEXTEDITING;
    pub const TextInput: u32 = SDL_TEXTINPUT;
    pub const UserEvent: u32 = SDL_USEREVENT;
    pub const WindowEvent: u32 = SDL_WINDOWEVENT;
};

pub fn nextEvent() ?SDL_Event {
    var ev: SDL_Event = undefined;
    var res = SDL_PollEvent(&ev);
    var res2 = ev.type;
    if (res == 0) {
        return null;
    } else {
        return ev;
    }
}
