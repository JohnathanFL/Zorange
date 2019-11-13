// This exposes the interface other systems see.
// For the actual renderer, see renderer.zig

// These are all indices into Renderer's arrays
pub const Texture = usize;
pub const VertBuff = usize;
pub const IndexBuff = usize;
pub const DynVertBuff = usize;
pub const DynIndexBuff = usize;
pub const Uniform = usize;
pub const Shader = usize;
pub const Program = usize;
pub const Framebuffer = usize;

const math = @import("math.zig");

pub const Camera = struct {
    /// Since only a very few will have this
    pub const storage = ecs.HashStorage(Camera);

    /// Where do we draw to?
    framebuffer: Framebuffer,
    proj: math.Matrix(f32, 4, 4),
    // Pos/rot are inherited from the node's transform
};
