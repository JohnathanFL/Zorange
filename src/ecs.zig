const std = @import("std");

// Here's the current idea: Each type actually manages its own storage
// Each type has a "storage" (static) var that the World interacts with
// If we need multiple worlds in the future, we can refactor so each type
// holds an ArrayList of storages (1 element for each world)
// This means that the world is essentially nothing more than an id manager

//pub const Serializer = fn(a: Component) []const []const u8;

// Note: This shouldn't be instantiated. It's just to show what interface is needed
const Storage = struct {
    pub const ID = usize; // A usize from TypeID
    pub const T = void; // The type we store

    /// Only gets it if it's there
    fn get(ent: Entity) ?*T;

    /// Sets it, no matter what. Returns the current value
    fn put(ent: Entity, new: T) *T;

    fn has(ent: Entity) bool;

    // Each Storage should additionally add the following to
    // the world's deleted_callbacks at compiletime
    fn delete(ent: Ent) void;

    // A list of all views which hold this component.
    pub var views: std.SegmentedList(*View, 128);
};

// Each storage registers this with the World
pub const EntityDeletedCallback = fn (Entity) void;

pub fn TypeID(comptime ty: type) usize {
    return std.hash_map.getAutoHashFn([]const u8)(@typeName(ty));
}

pub fn VecStorage(comptime T: type, comptime alloc: *std.mem.Allocator) type {
    const S = struct {
        pub const ID = TypeID(T);
        // Why do I feel so dirty after writing things like this?
        var storage: std.ArrayList(?T) = std.ArrayList(?T).init(alloc);

        fn get(ent: Entity) ?*T {
            const slice = storage.toSlice();
            if (slice.len - 1 >= ent.id) {
                if (slice[ent.id]) |*val| {
                    return val;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        }

        fn put(ent: Entity, new: T) *T {
            storage.insert(ent.id, new) catch unreachable;
            return &storage.toSlice()[ent.id].?;
        }

        fn has(ent: Entity) bool {
            const slice = storage.toSlice();
            if (slice.len - 1 >= ent.id) {
                if (slice[ent.id]) |_| {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        fn deleteEnt(ent: Entity) void {}
    };

    return S;
}

pub const Entity = struct {
    id: usize,

    // The following are simply all sugar methods for the world.***Component funcs

    // TODO: the returned pointer can't safely be kept because of entity addition/removal
    // UNLESS the Storage type is a SegmentedList or similar
    pub fn getComponent(self: Entity, comptime ty: type) ?*ty {
        return World.getComponent(self, ty);
    }

    pub fn putComponent(self: Entity, comptime ty: type, val: ty) *ty {
        return World.putComponent(self, ty, val);
    }

    pub fn hasComponent(self: Entity, comptime ty: type) bool {
        return World.hasComponent(self, ty);
    }

    pub fn hasComponents(self: Entity, comptime tys: []const type) bool {
        return World.hasComponents(self, tys);
    }
};

// A list of all ents having a certain set of components
pub const View = struct {
    ents: std.AutoHashMap(Entity, void),
};

pub const World = struct {
    // Sure singletons are supposed to be bad, but I really can't see a reason
    // for multiple Worlds in this context. Either way, it's all pretty abstracted,
    // so if needed we can just move to an ArrayList of Worlds or something like
    // that


    // I figure this is a good default.
    // Individual projects can just change it
    // (or I can make World a fn that takes it)
    // Mods will probably neccesitate raising this, but that
    // can be done later (if it makes it that far)
    const MAX_COMPONENTS = 128;

    // A bitfield of which components each Entity has (indexed by Entity.id)
    // TODO: Waiting on a way to assign a unique 0..MAX_COMPONENTS ID to each component
    var ent_comps: std.ArrayList([MAX_COMPONENTS]u1);

    var next_id: usize = 0;
    // When an entity is destroyed, it pushes the index onto this and nulls all its existing components nulled
    var free_ids: std.AutoHashMap(usize, void) = undefined;
    var used_ids: std.AutoHashMap(usize, void) = undefined;

    // 128 here has no relation to MAX_COMPONENTS. Perfectly arbitrary.
    // Note: This means creating and discarding Views is discouraged
    var views: std.SegmentedList(View, 128) = undefined;

    pub fn newEnt() Entity {
        var ret = Entity{
            .id = next_id,
        };

        used_ids.putNoClobber(next_id, {}) catch unreachable;
        next_id += 1;
        return ret;
    }

    pub fn destroyEnt(ent: Entity) !void {
        try self.freeIDs.putNoClobber(ent.id, {});
        // We'll handle deiniting components by callbacks
    }

    pub fn init(alloc: *std.mem.Allocator) void {
        next_id = 0;
        free_ids = std.AutoHashMap(usize, void).init(alloc);
        used_ids = std.AutoHashMap(usize, void).init(alloc);
        views = std.SegmentedList(View, 128).init(alloc);
    }

    pub fn allWith(comptime tys: []const type) *View {
        _ = views.push(View{ .ents = std.AutoHashMap(Entity, void).init(views.allocator) }) catch unreachable;
        var view = views.at(views.len - 1);
        var iter = used_ids.iterator();
        while (iter.next()) |kvp| {
            var ent = Entity{ .id = kvp.key };
            if (ent.hasComponents(tys))
                view.ents.putNoClobber(ent, {}) catch unreachable;
        }

        return view;
    }

    pub fn putComponent(ent: Entity, comptime ty: type, val: ty) *ty {
        return ty.storage.put(ent, val);
    }

    pub fn getComponent(ent: Entity, comptime ty: type) ?*ty {
        return ty.storage.get(ent);
    }

    pub fn hasComponent(ent: Entity, comptime ty: type) bool {
        return ty.storage.has(ent);
    }

    pub fn hasComponents(ent: Entity, comptime tys: []const type) bool {
        inline for (tys) |ty| {
            if (!hasComponent(ent, ty)) return false;
        }
        return true;
    }

    pub fn destroy() void {
        free_ids.deinit();
    }
};

test "ecs" {
    World.init(std.heap.c_allocator);
    var john = World.newEnt();
    _ = john.putComponent(Name, Name{ .name = "Johnnyboy" });
    _ = john.putComponent(Hair, Hair.ShitTon);
    testing.expect(john.hasComponent(Name));
    testing.expect(john.hasComponents([_]type{ Name, Hair }));

    var james = World.newEnt();
    _ = james.putComponent(Name, Name{ .name = "James" });

    {
        const view = World.allWith([_]type{Name});
        printf("{}", view.ents.count() == 2);
    }

    {
        const view = World.allWith([_]type{ Name, Hair });
        printf("{}", view.ents.count() == 1);
    }
}
