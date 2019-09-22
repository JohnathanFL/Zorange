const std = @import("std");
const testing = std.testing;

const SDL = @import("sdl.zig");
const Flags = SDL.Flags;
const InitMode = SDL.InitMode;

// const otherTransform = ecs.Transform;
// const a = getType(u2);
// const b = getType(u2);
// comptime {@compileLog(@typeName(a));}
// comptime {@compileLog(@typeName(b));}

const getType = ecs.getType;
use @import("ecs.zig");

use @import("math.zig");

pub fn main() anyerror!void {
    // std.debug.warn("{}", x.items);

    // var reg = Registry.init();
    // defer reg.destroy();
    
    // var john = reg.newEnt();
    // var comp = reg.addComponent(john, Name, Name{.name = "Johnathan"});

    // std.debug.warn("Hello, {s}", john.getComponent(Name).?.name);

    // try SDL.init(Flags.with(InitMode.Video));
    // defer SDL.quit();

    // try SDL.GLAttr.MajorVersion.set(4);
    // try SDL.GLAttr.MinorVersion.set(5);
    // try SDL.GLAttr.ProfileMask.set(SDL.GLProfile.Core.asCInt());

    // var window = try SDL.Window.create(c"zorange", 0, 0, 1600, 900, Flags.with(SDL.Window.OpenGL));
    // defer window.destroy();

    // var context = try window.createGLContext();
    // defer context.destroy();

    // var running = true;
    // while (running) {
    //     while (SDL.nextEvent()) |event| {
    //         if (event.type == SDL.EventType.Quit) {
    //             running = false;
    //         } else if (event.type == SDL.EventType.KeyDown) {
    //             if (event.key.keysym.sym == SDL.SDLK_ESCAPE) {
    //                 running = false;
    //             }
    //         }
    //     }

    //     glClearColor(1.0, 1.0, 1.0, 1.0);
    //     glClear(GL_COLOR_BUFFER_BIT);
    //     window.swapGL();
    // }

}
