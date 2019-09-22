const std = @import("std");

// pub const Serializer = fn(a: Component) []u8 

pub const NoSerialize: type = undefined;

pub const StorageInterface = struct {
    pub init: fn(alloc: *std.Allocator) StorageInterface,

    pub get: fn(self: @This(), ent: Entity) ?*void,

    pub has: fn(self: @This(), ent: Entity) *void,

    pub add: fn(self: *@This(), ent: Entity, comp: ty) *void,
};

pub fn VecStorage(comptime ty: type) type {
    return struct {
        const Comp = struct {
            data: ty,
            present: bool
        };

        internal: std.SegmentedList(Comp, 32),

        pub fn init(alloc: *std.mem.Allocator) @This() {
            return @This() {
                .internal = std.ArrayList(ty).init(alloc)
            };
        }

        pub fn get(self: *@This(), ent: Entity) ?*ty {
            if (ent.id >= self.internal.count()) {
                return null;
            }

            var comp = self.internal.at(ent.id);
            if(comp.present) {
                return &comp.data;
            } else {
                return null;
            }
        }

        pub fn has(self: *@This(), ent: Entity) bool {
            return self.get(ent) != null;
        }

        pub fn add(self: *@This(), ent: Entity, comp: ty) *ty {
            std.debug.warn("FAILED TO GROW\n");
            self.internal.growCapacity(ent.id + 1) catch unreachable;
            var loc = self.internal.at(ent.id);
            loc.* = Comp {
                .data = comp,
                .present = true
            };

            return &loc.data;
        }
    };
}
pub fn HashStorage(comptime ty: type) type {
    return std.AutoHashMap(comptime []const u8, ty);
}

pub fn TypeID(comptime ty: type) usize {
    return std.hash_map.getAutoHashFn([]const u8)(@typeName(ty));
}

// comptime {@compileLog(@typeName(VecStorage));}

pub const Transform = struct {
    pub const TypeName = @typeName(@This());
    
    pub const Serialize = NoSerialize;
    pub const Storage = VecStorage;

    pub pos: @Vector(3, f32),
    pub rot: @Vector(4, f32),
    pub scale: @Vector(3, f32),
};

pub const Name = struct {
    pub name: []const u8,
    
    pub const Serialize = NoSerialize;
    pub const Storage = VecStorage(@This());
};

pub const Entity = struct {
    id: usize,
    registry: *Registry,

    // The following are simply all sugar methods for the registry.***Component funcs

    // TODO: the returned pointer can't safely be kept because of entity addition/removal
    // UNLESS the Storage type is a SegmentedList or similar
    pub fn getComponent(self: Entity, comptime ty: type) ?*ty {
        return self.registry.getComponent(self, ty);
    }

    pub fn addComponent(self: Entity, comptime ty: type, val: ty) ?*ty {
        return self.registry.addComponent(self, ty, val);
    }

    pub fn hasComponent(self: Entity, comptime ty: type) bool {
        return self.registry.hasComponent(self, ty);
    }
};

pub const Registry = struct {

    allocator: *std.mem.Allocator,
    // TypeID to storage for that type. Type of storage determined by "ty.Storage"
    // Each *void points to a structure with a .get(Entity)->*Component 
    compLists: std.AutoHashMap(usize, *void), 
    
    nextID: usize,
    // When an entity is destroyed, it pushes the index onto this and nulls all its existing components nulled
    freeIDs: std.ArrayList(usize), 

    pub fn newEnt(self: *Registry) Entity {
        var ret = Entity {
            .id = self.nextID,
            .registry = self
        };

        self.nextID += 1;
        return ret;

    }

    pub fn destroyEnt(self: *Registry, ent: Entity) void {
        self.freeIDs.push(ent.id);
        // TODO: for ent's component -> deinit
    }

    pub fn init() Registry {
        const alloc = std.heap.c_allocator;
        return Registry {
            .allocator = alloc,
            .compLists = std.AutoHashMap(usize, *void).init(alloc),
            .nextID = 0,
            .freeIDs = std.ArrayList(usize).init(alloc),
        };
    }

    fn getStorage(self: *Registry, comptime ty: type) *ty.Storage {
        var res = self.compLists.getOrPut(TypeID(ty)) catch @panic("Failed to getOrPut");
        var list = @ptrCast(*ty.Storage, res.kv.value);

        if (!res.found_existing) {
            list.* = ty.Storage.init(self.allocator);
        }

        
        return list;
    }

    // If comp already exists, it just returns that
    // In other words, it always acts as a getOrAddComponent
    pub fn addComponent(self: *Registry, ent: Entity, comptime ty: type, val: ty) *ty {
        var storage = self.getStorage(ty);
        return storage.add(ent, val);
    }

    pub fn getComponent(self: *Registry, ent: Entity, comptime ty: type) ?*ty {
        var storage = self.getStorage(ty);
        return storage.get(ent);
    }

    pub fn hasComponent(self: Registry, ent: Entity, comptime ty: type) bool {
        var storage = self.getStorage(ty);
        return storage.has(ent);
    }

    pub fn destroy(self: *Registry) void {
        self.compLists.deinit();
        self.freeIDs.deinit();
    }
};