package Components

import rl "vendor:raylib"

Plane :: struct {
    normal: rl.Vector3,
    distance: f32,
}

Frustum :: struct {
    planes: [6]Plane, // Left, Right, Bottom, Top, Near, Far
}
