﻿package Systems

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
    player_entity.transform.scale = rl.Vector3{0.1, 0.0, 0.0}
    player_entity.model = rl.LoadModel("Data/space_ranger_sr1_gltf/scene.gltf")
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

        draw_world_bounds(game_state)
        draw_player(game_state)
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

    target_distance := 15.0 * player_entity.transform.scale.x
    local_offset := rl.Vector3{0.0, 2.0, 0.0} * player_entity.transform.scale.x

    // Target is player ship and player position.
    game_state.camera.target = player_entity.transform.translation + local_offset

    // Update camera angle.
    game_state.camera_angle.x += camera_rotation.x
    game_state.camera_angle.y -= camera_rotation.y
    // Limit vertical angle.
    game_state.camera_angle.y = rl.Clamp(game_state.camera_angle.y, -rl.PI*0.49, rl.PI*0.49)
    game_state.camera_angle.x = math.mod_f32(game_state.camera_angle.x, rl.PI*2)

    // Calculate new target position based on angles.
    game_state.camera.position.x = game_state.camera.target.x - math.cos(game_state.camera_angle.y) * math.cos(game_state.camera_angle.x) * target_distance
    game_state.camera.position.y = game_state.camera.target.y - math.sin(game_state.camera_angle.y) * target_distance
    game_state.camera.position.z = game_state.camera.target.z - math.cos(game_state.camera_angle.y) * math.sin(game_state.camera_angle.x) * target_distance
}

draw_world_bounds :: proc(game_state: ^Entities.GameState) {
    // Debug draw world bounds.
    min_world_pos := rl.Vector3{0.0, 0.0, 0.0}
    max_world_pos := rl.Vector3{Constants.WORLD_SIZE, Constants.WORLD_SIZE, Constants.WORLD_SIZE}
    world_center := (max_world_pos - min_world_pos)/2

    num_iterations :: 3

    // Draw 3x larger world bounds
    for x in -num_iterations..=num_iterations {
        for y in -num_iterations..=num_iterations {
            for z in -num_iterations..=num_iterations {
                rl.DrawCubeWires(world_center + rl.Vector3{f32(x)*max_world_pos.x, f32(y)*max_world_pos.y, f32(z)*max_world_pos.z},
                Constants.WORLD_SIZE, Constants.WORLD_SIZE, Constants.WORLD_SIZE, rl.BLUE)
            }
        }
    }

    // Draw world bounds.
    rl.DrawCubeWires(world_center, max_world_pos.x, max_world_pos.y, max_world_pos.z, rl.RED)
}

draw_player :: proc(game_state: ^Entities.GameState) {
    player_entity := get_player_entity(game_state)
    // Custom model transform.
    local_position_offset := rl.Vector3{-12.0, -3.0, -2.0}
    local_translation := rl.MatrixTranslate(local_position_offset.x, local_position_offset.y, local_position_offset.z)

    rotation_matrix := rl.QuaternionToMatrix(player_entity.transform.rotation)
    rotation_matrix = rl.MatrixLookAt(
        rl.Vector3{0.0, 0.0, 0.0},
        rl.Vector3{0.0, 1.0, 0.0},
        rl.Vector3{0.0, 0.0, 1.0}) * rotation_matrix

    // Rotate model.
    player_entity.model.transform = rotation_matrix * local_translation

    // Draw player model.
    rl.DrawModel(player_entity.model, player_entity.transform.translation, player_entity.transform.scale.x, rl.WHITE)

    // Draw debug sphere around player position.
    when (false) {
        model_bounds := rl.GetModelBoundingBox(player_entity.model)
        model_size := rl.Vector3Distance(model_bounds.min, model_bounds.max) * player_entity.transform.scale.x
        rl.DrawSphereWires(player_entity.transform.translation, model_size/2, 8, 8, rl.GREEN)
    }
}

vec2_to_string :: proc(text: cstring, v: rl.Vector2) -> cstring {
    return rl.TextFormat("%s(%.2f, %.2f)", text, v.x, v.y)
}

vec3_to_string :: proc(text: cstring, v: rl.Vector3) -> cstring {
    return rl.TextFormat("%s(%.2f, %.2f, %.2f)", text, v.x, v.y, v.z)
}