package Systems

import rl "vendor:raylib"
import "core:math"
import "../Constants"
import "../Entities"
import "../UI"

start_game :: proc(game_state: ^Entities.GameState) {
    rl.DisableCursor()

    game_state.level_tag = Entities.LevelTag.GameLevel
    game_state.score = 0
    game_state.camera = rl.Camera{
        position = rl.Vector3{1.0, 1.0, 1.0},
        target = rl.Vector3{0.0, 0.0, 0.0},
        up = rl.Vector3{0.0, 1.0, 0.0},
        fovy = 60.0,
        projection = rl.CameraProjection.PERSPECTIVE,
    }

    // Spawn player entity.
    new_entity := Entities.new_entity(Entities.Player)
    player_entity := &new_entity.derived.(Entities.Player)
    player_entity.transform.translation = rl.Vector3{Constants.WORLD_SIZE/2, Constants.WORLD_SIZE/2, Constants.WORLD_SIZE/2}
    player_entity.transform.rotation = rl.QuaternionFromEuler(0.0, 0.0, 0.0)
    //player_entity.model = rl.LoadModel("Data/space_ranger_sr1_gltf/scene.gltf")
    append(&game_state.entities, player_entity)
}

run_game :: proc(game_state: ^Entities.GameState) -> bool {
    // Clear background
    rl.ClearBackground(rl.BLACK)
    delta_time := rl.GetFrameTime()

    // Update UI data.
    switch &e in game_state.menu_state.derived {
    case UI.GameHudState:
        // Update score.
        game_hud_state := &e.derived.(UI.GameHudState)
        game_hud_state.score = game_state.score
    }

    // Update camera.
    update_camera(game_state, delta_time)

    // Draw world.
    {
        rl.BeginMode3D(game_state.camera)
        defer rl.EndMode3D()

        // Debug draw world bounds.
        min_world_pos := rl.Vector3{0.0, 0.0, 0.0}
        max_world_pos := rl.Vector3{Constants.WORLD_SIZE, Constants.WORLD_SIZE, Constants.WORLD_SIZE}
        world_center := (max_world_pos - min_world_pos)/2

        // Draw 3x larger world bounds
        for x in -2..<3 {
            for y in -2..<3 {
                for z in -2..<3 {
                    rl.DrawCubeWires(world_center + rl.Vector3{f32(x)*max_world_pos.x, f32(y)*max_world_pos.y, f32(z)*max_world_pos.z},
                        Constants.WORLD_SIZE, Constants.WORLD_SIZE, Constants.WORLD_SIZE, rl.GREEN)
                }
            }
        }

        // Draw world bounds.
        rl.DrawCubeWires(world_center, max_world_pos.x, max_world_pos.y, max_world_pos.z, rl.RED)
    }

    // Run all game systems.
    system_player_movement(game_state, delta_time)
    system_asteroid_movement(game_state, delta_time)
    system_asteroid_spawn(game_state, delta_time)

    return true
}

close_game :: proc(game_state: ^Entities.GameState) {
    // Delete all entities.
    delete(game_state.entities)
}

update_camera :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update camera rotation directly from mouse input.
    camera_rotation := rl.Vector3{0.0, 0.0, 0.0}
    camera_rotation.x = rl.GetMouseDelta().x * game_state.mouse_speed * delta_time
    camera_rotation.y = rl.GetMouseDelta().y * game_state.mouse_speed * delta_time
    // Calculate change of camera position from camera position and new player position.
    player_entity := get_player_entity(game_state)

    //position_delta := (player_entity.transform.translation - game_state.camera.position) * delta_time
    //rl.UpdateCamera(&game_state.camera, rl.CameraMode.CUSTOM)
    //rl.UpdateCameraPro(&game_state.camera, position_delta, camera_rotation, 0.0)
    game_state.camera.position = player_entity.transform.translation

    // Update camera angle.
    game_state.camera_angle.x += camera_rotation.x
    game_state.camera_angle.y -= camera_rotation.y
    // Limit vertical angle.
    game_state.camera_angle.y = rl.Clamp(game_state.camera_angle.y, -rl.PI*0.49, rl.PI*0.49)
    game_state.camera_angle.x = math.mod_f32(game_state.camera_angle.x, rl.PI*2)

    // Calculate new target position based on angles.
    target_distance :: 10.0
    game_state.camera.target.x = game_state.camera.position.x + math.cos(game_state.camera_angle.y) * math.cos(game_state.camera_angle.x) * target_distance
    game_state.camera.target.y = game_state.camera.position.y + math.sin(game_state.camera_angle.y) * target_distance
    game_state.camera.target.z = game_state.camera.position.z + math.cos(game_state.camera_angle.y) * math.sin(game_state.camera_angle.x) * target_distance
}

vec2_to_string :: proc(text: cstring, v: rl.Vector2) -> cstring {
    return rl.TextFormat("%s(%.2f, %.2f)", text, v.x, v.y)
}

vec3_to_string :: proc(text: cstring, v: rl.Vector3) -> cstring {
    return rl.TextFormat("%s(%.2f, %.2f, %.2f)", text, v.x, v.y, v.z)
}