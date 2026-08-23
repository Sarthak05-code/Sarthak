const std = @import("std");

pub const GaussSeidel = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,

    pub fn init(self: *GaussSeidel, x: f32, y: f32, z: f32) void {
        self.x = x;
        self.y = y;
        self.z = z;
    }

    pub fn iter(self: *GaussSeidel, epsilon: f32) bool {
        const x_prev = self.x;
        const y_prev = self.y;
        const z_prev = self.z;

        self.x = (17.0 - self.y + 2.0 * self.z) / 20.0;
        self.y = (-18.0 - 3.0 * self.x + self.z) / 20.0;
        self.z = (25.0 - 2.0 * self.x + 3.0 * self.y) / 20.0;

        const dx = @abs(self.x - x_prev);
        const dy = @abs(self.y - y_prev);
        const dz = @abs(self.z - z_prev);

        return dx < epsilon and
            dy < epsilon and
            dz < epsilon;
    }
};

pub fn main() !void {
    var solver = GaussSeidel{};
    solver.init(0.0, 0.0, 0.0);

    const max_iter: usize = 100;
    const epsilon: f32 = 0.0001;

    var count: usize = 1;

    while (count <= max_iter) : (count += 1) {
        const converged = solver.iter(epsilon);

        std.debug.print(
            "Iteration {}: x = {d:.4}, y = {d:.4}, z = {d:.4}\n",
            .{
                count,
                solver.x,
                solver.y,
                solver.z,
            },
        );

        if (converged) {
            std.debug.print(
                "\nConverged successfully in {} iterations!\n",
                .{count},
            );
            break;
        }
    } else {
        std.debug.print(
            "\nReached max iterations without convergence.\n",
            .{},
        );
    }
}
