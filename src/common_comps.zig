const ecs = @import("ecs.zig");
const math = @import("math.zig");

pub const Position = struct {
  pub const storage = ecs.VecStorage(Position);

  pos: math.Vec3(f32),
  cur: u8,
};

pub const Rotation = struct {
    pub const storage = ecs.VecStorage(Rotation);

    rot: math.Quat(f32),
    cur: u8
};

pub const Scale = struct {
    pub const storage = ecs.VecStorage(Scale);
    scale: math.Vec3(f32),
    cur: u8
};

pub const CachedTransform = struct {
    pub const storage = ecs.VecStorage(Transform);

    cached: math.Matrix(f32, 4, 4),
    /// If this doesn't match Position.cur, then this is dirty
    last_pos: u8,
    /// If this doesn't match Rotation.cur, then this is dirty
    last_rot: u8,
    /// If this doesn't match Scale.cur, then this is dirty
    last_scale: u8,
};

pub const Name = struct {
    pub const storage = ecs.VecStorage(Name);
  
    str: []const u8,
};

