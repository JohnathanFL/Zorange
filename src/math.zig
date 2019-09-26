const std = @import("std");



pub fn Matrix(comptime N: u8, comptime M: u8, comptime T: type) type {
    return packed struct {
        pub const Elem = T;
        pub const Width = N;
        pub const Height = M;

        index: [Width][Height]Elem,

        pub fn add(lhs: @This(), rhs: @This()) @This() {
            var res = lhs;

            comptime var i = 0;
            inline while (i < T.Width) : (i += 1) {
                comptime var j = 0;
                inline while (j < T.Height) : (j += 1) {
                    res.index[i][j] += rhs.index[i][j];
                }
            }

            return res;
        }

        pub fn scale(lhs: @This(), scalar: Elem) @This() {
            var res = lhs;
            for (res.index) |*row| {
                for (row) |*column| {
                    *column *= scalar;
                }
            }
        }

        // Specialization of scale for -1
        pub fn negate(lhs: @This()) @This() {
            var res = lhs;
            for (res.index) |*row| {
                for (row) |*column| {
                    *column *= -*column;
                }
            }
        }

        pub fn sub(lhs: @This(), rhs: @This()) @This() {
            return lhs.add(rhs.negate());
        }

        pub fn mul(lhs: @This(), comptime P: u8, rhs: Matrix(M, P, Elem)) Matrix(N, P, Elem) {
            var res: Matrix(Width, P, Elem) = undefined;
            comptime var i = 0;
            inline while (i < N) : (i += 1) {
                comptime var j = 0;
                inline while (j < P) : (j += 1) {
                    var sum: Elem = 0;
                    comptime var k = 0;
                    inline while (k < M) : (k += 1) sum += lhs.index[i][k] * rhs.index[k][j];
                    res.index[i][j] = sum;
                }
            }

            return res;
        }

        // Composing matrices of the same size
        pub fn composite(lhs: @This(), rhs: @This()) @This() {
            return lhs.mul(N, rhs);
        }

    };
}

pub fn Quat(comptime T: type) type {
    return packed struct {
        pub const Elem = T;
        pub const Num = 4;

        pub x: Elem,
        pub y: Elem,
        pub z: Elem,
        pub w: Elem,

        pub fn normalize(self: *@This()) void {
            var length = self.magnitude();
            self.x /= length;
            self.y /= length;
            self.z /= length;
            self.w /= length;
        }

        pub fn normalized(self: @This()) @This() {
            var res = self;
            res.normalize();
            return res;
        }

        pub fn mag(self: @This()) Elem {
            return @sqrt(Elem, self.x * self.x + self.y * self.y + self.z * self.z);
        }

        pub fn magSqr(self: @This()) Elem {
            var res = self.mag();
            return res * res;
        }
    };
}

pub fn Vec3(comptime T: type) type {
    return packed struct {
        pub const Elem = T;
        pub const Num = 3;

        pub x: Elem,
        pub y: Elem,
        pub z: Elem,

        pub inline fn add(self: @This(), rhs: @This()) @This() {
            return @This(){
                .x = self.x + rhs.x,
                .y = self.y + rhs.y,
                .z = self.z + rhs.z,
            };
        }

        pub inline fn negate(self: @This()) @This() {
            return @This(){
                .x = -self.x,
                .y = -self.y,
                .z = -self.z,
            };
        }

        pub inline fn sub(self: @This(), rhs: @This()) @This() {
            return self.add(rhs.negate());
        }

        pub inline fn scale(self: @This(), scalar: E) @This() {
            return @This(){
                .x = self.x * scalar,
                .y = self.x * scalar,
                .z = self.z * scalar,
            };
        }

        pub inline fn dot(self: @This(), rhs: @This()) Elem {
            return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
        }

        pub inline fn cross(self: @This(), rhs: @This()) @This() {
            return @This(){
                .x = self.y * rhs.z - self.z * rhs.y,
                .y = self.z * rhs.x - self.x * rhs.z,
                .z = self.x * rhs.y - self.y * rhs.x,
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
            return @This(){
                .x = self.x + rhs.x,
                .y = self.y + rhs.y,
            };
        }

        pub inline fn negate(self: @This()) @This() {
            return @This(){
                .x = -self.x,
                .y = -self.y,
            };
        }

        pub inline fn sub(self: @This(), rhs: @This()) @This() {
            return self.add(rhs.negate());
        }

        pub inline fn scale(self: @This(), scalar: E) @This() {
            return @This(){
                .x = self.x * scalar,
                .y = self.x * scalar,
            };
        }

        pub inline fn dot(self: @This(), rhs: @This()) Elem {
            return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
        }
    };
}
