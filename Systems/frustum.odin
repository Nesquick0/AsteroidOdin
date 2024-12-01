package Systems

import rl "vendor:raylib"
import "core:math"
import "../Components"
import "../Entities"

//create_frustum :: proc(camera: ^rl.Camera) -> ^Components.Frustum {
//    // Create frustum.
//    frustum := new(Components.Frustum)
//    frustum.planes[0].normal = rl.Vector3{1.0, 0.0, 0.0}
//    frustum.planes[0].distance = camera.position.x
//    frustum.planes[1].normal = rl.Vector3{-1.0, 0.0, 0.0}
//    frustum.planes[1].distance = -camera.position.x
//    frustum.planes[2].normal = rl.Vector3{0.0, 1.0, 0.0}
//    frustum.planes[2].distance = camera.position.y
//    frustum.planes[3].normal = rl.Vector3{0.0, -1.0, 0.0}
//    frustum.planes[3].distance = -camera.position.y
//    frustum.planes[4].normal = rl.Vector3{0.0, 0.0, 1.0}
//    frustum.planes[4].distance = camera.position.z
//    frustum.planes[5].normal = rl.Vector3{0.0, 0.0, -1.0}
//    frustum.planes[5].distance = -camera.position.z
//    return frustum
//}

// Creates a frustum from view-projection matrix
update_frustum :: proc(view_proj: rl.Matrix, frustum: ^Components.Frustum) {
    // Left plane
    frustum.planes[0].normal.x = view_proj[3][0] + view_proj[0][0]
    frustum.planes[0].normal.y = view_proj[3][1] + view_proj[0][1]
    frustum.planes[0].normal.z = view_proj[3][2] + view_proj[0][2]
    frustum.planes[0].distance = view_proj[3][3] + view_proj[0][3]

    // Right plane
    frustum.planes[1].normal.x = view_proj[3][0] - view_proj[0][0]
    frustum.planes[1].normal.y = view_proj[3][1] - view_proj[0][1]
    frustum.planes[1].normal.z = view_proj[3][2] - view_proj[0][2]
    frustum.planes[1].distance = view_proj[3][3] - view_proj[0][3]

    // Bottom plane
    frustum.planes[2].normal.x = view_proj[3][0] + view_proj[1][0]
    frustum.planes[2].normal.y = view_proj[3][1] + view_proj[1][1]
    frustum.planes[2].normal.z = view_proj[3][2] + view_proj[1][2]
    frustum.planes[2].distance = view_proj[3][3] + view_proj[1][3]

    // Top plane
    frustum.planes[3].normal.x = view_proj[3][0] - view_proj[1][0]
    frustum.planes[3].normal.y = view_proj[3][1] - view_proj[1][1]
    frustum.planes[3].normal.z = view_proj[3][2] - view_proj[1][2]
    frustum.planes[3].distance = view_proj[3][3] - view_proj[1][3]

    // Near plane
    frustum.planes[4].normal.x = view_proj[3][0] + view_proj[2][0]
    frustum.planes[4].normal.y = view_proj[3][1] + view_proj[2][1]
    frustum.planes[4].normal.z = view_proj[3][2] + view_proj[2][2]
    frustum.planes[4].distance = view_proj[3][3] + view_proj[2][3]

    // Far plane
    frustum.planes[5].normal.x = view_proj[3][0] - view_proj[2][0]
    frustum.planes[5].normal.y = view_proj[3][1] - view_proj[2][1]
    frustum.planes[5].normal.z = view_proj[3][2] - view_proj[2][2]
    frustum.planes[5].distance = view_proj[3][3] - view_proj[2][3]

    // Normalize all planes
    for &plane in &frustum.planes {
        len := rl.Vector3Length(plane.normal)
        plane.normal /= len
        plane.distance /= len
    }
}

// Create frustum from raylib camera
update_frustum_from_camera :: proc(camera: ^rl.Camera, aspect_ratio: f32, frustum: ^Components.Frustum, game_state: ^Entities.GameState) {
    position := rl.Vector3{camera.position.x, camera.position.y, camera.position.z}
    target := rl.Vector3{camera.target.x, camera.target.y, camera.target.z}
    up := rl.Vector3{camera.up.x, camera.up.y, camera.up.z}

    // Create view matrix
    forward := rl.Vector3Normalize(target - position)
    right := rl.Vector3Normalize(rl.Vector3CrossProduct(forward, up))
    up = rl.Vector3Normalize(rl.Vector3CrossProduct(right, forward))

    view := rl.Matrix{
        right.x,   up.x,   -forward.x, 0,
        right.y,   up.y,   -forward.y, 0,
        right.z,   up.z,   -forward.z, 0,
        -rl.Vector3DotProduct(right, position), -rl.Vector3DotProduct(up, position), rl.Vector3DotProduct(forward, position), 1,
    }

    // Create projection matrix
    fovy := camera.fovy
    near : f32 = 0.1  // You might want to make these configurable
    far : f32 = 1000.0

    f := 1.0 / math.tan(fovy * 0.5 * math.PI / 180.0)
    projection := rl.Matrix{
        f/aspect_ratio, 0, 0, 0,
        0, f, 0, 0,
        0, 0, (far+near)/(near-far), -1,
        0, 0, (2*far*near)/(near-far), 0,
    }

    // Combine view and projection matrices
    view_proj := projection * view

    // Create frustum using the previous function
    if (rl.IsKeyPressed(.F5)) {
        game_state.update_frustum = !game_state.update_frustum
    }
    if (game_state.update_frustum) {
        update_frustum(view_proj, frustum)
    }

    when (true) {
        // Debug draw frustum.
        for &plane in &frustum.planes {
            plane_forward := rl.Vector3Normalize(rl.Vector3CrossProduct(plane.normal, right))
            player_entity := get_player_entity(game_state)
            start_pos := player_entity.transform.translation
            rl.DrawLine3D(start_pos + forward, start_pos + plane_forward * 100.0, rl.GREEN)
        }
    }
}


// Check if a point is inside the frustum
point_in_frustum :: proc(frustum: ^Components.Frustum, point: rl.Vector3) -> bool {
    for plane in frustum.planes {
        if rl.Vector3DotProduct(plane.normal, point) + plane.distance < 0 {
            return false
        }
    }
    return true
}

// Check if a sphere is inside or intersects the frustum
sphere_in_frustum :: proc(frustum: ^Components.Frustum, center: rl.Vector3, radius: f32) -> bool {
    for plane in frustum.planes {
        if rl.Vector3DotProduct(plane.normal, center) + plane.distance < -radius {
            return false
        }
    }
    return true
}

// Check if an axis-aligned bounding box is inside or intersects the frustum
aabb_in_frustum :: proc(frustum: ^Components.Frustum, min, max: rl.Vector3) -> bool {
    for plane in frustum.planes {
        p := min
        n := max

        if plane.normal.x >= 0 {
            p.x = max.x
            n.x = min.x
        }
        if plane.normal.y >= 0 {
            p.y = max.y
            n.y = min.y
        }
        if plane.normal.z >= 0 {
            p.z = max.z
            n.z = min.z
        }

        if rl.Vector3DotProduct(plane.normal, p) + plane.distance < 0 {
            return false
        }
    }
    return true
}