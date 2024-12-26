package Systems

import rl "vendor:raylib"
import "../Components"
import "../Entities"

update_frustum_from_camera :: proc(camera: ^rl.Camera, aspect_ratio: f32, frustum: ^Components.Frustum, game_state: ^Entities.GameState) {
    mat_view := rl.GetCameraMatrix(camera^)
    mat_proj := rl.MatrixPerspective(camera.fovy*rl.DEG2RAD, aspect_ratio, 0.1, game_state.draw_distance)
    mat_view_proj := mat_proj * mat_view

    // Create frustum using the previous function
    /*if (rl.IsKeyPressed(.F5)) {
        game_state.update_frustum = !game_state.update_frustum
    }*/
    if (game_state.update_frustum) {
        update_frustum(mat_view_proj, frustum)
    }
}

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