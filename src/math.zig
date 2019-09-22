const std = @import("std");



pub fn Vec3(comptime T: type) type {
    return packed struct {
        pub const Elem = T;
        pub const Num = 2;

        pub x: Elem,
        pub y: Elem,
        pub z: Elem,

        pub inline fn add(self: @This(), rhs: @This()) @This() {
            return @This() {
                .x = self.x + rhs.x,
                .y = self.y + rhs.y,
                .z = self.z + rhs.z,
            };
        }

        pub inline fn negate(self: @This()) @This() {
            return @This() {
                .x = -self.x,
                .y = -self.y,
                .z = -self.z
            };
        }

        pub inline fn sub(self: @This(), rhs: @This()) @This() {
            return self.add(rhs.negate());
        }

        pub inline fn scale(self: @This(), scalar: E) @This() {
            return @This() {
                .x = self.x * scalar,
                .y = self.x * scalar,
                .z = self.z * scalar
            };
        }

        pub inline fn dot(self: @This(), rhs: @This()) Elem {
            return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
        }

        pub inline fn cross(self: @This(), rhs: @This()) @This() {
            return @This() {
                .x = self.y * rhs.z - self.z * rhs.y,
                .y = self.z * rhs.x - self.x * rhs.z,
                .z = self.x * rhs.y - self.y * rhs.x
            };
        }


    };
}


// Literally made by copy/pasting Vec3 and deleting stuff
pub fn Vec2(comptime T: type) type {
    return packed struct {
        pub const Elem = T;
        pub const Num = 2;

        pub x: Elem,
        pub y: Elem,

        pub inline fn add(self: @This(), rhs: @This()) @This() {
            return @This() {
                .x = self.x + rhs.x,
                .y = self.y + rhs.y,
            };
        }

        pub inline fn negate(self: @This()) @This() {
            return @This() {
                .x = -self.x,
                .y = -self.y,
            };
        }

        pub inline fn sub(self: @This(), rhs: @This()) @This() {
            return self.add(rhs.negate());
        }

        pub inline fn scale(self: @This(), scalar: E) @This() {
            return @This() {
                .x = self.x * scalar,
                .y = self.x * scalar,
            };
        }

        pub inline fn dot(self: @This(), rhs: @This()) Elem {
            return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
        }
    };
}