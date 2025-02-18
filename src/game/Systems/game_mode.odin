﻿#+vet !unused-imports
package Systems

import rl "../../../raylib"
import "core:math"
import "../Constants"
import "../Entities"
import "../UI"
import "core:fmt"

start_game :: proc(game_state: ^Entities.GameState) {
    rl.DisableCursor()

    game_state.start_time = rl.GetTime()
    game_state.level_tag = Entities.LevelTag.GameLevel
    game_state.score = 0
    game_state.game_over = false
    game_state.camera = rl.Camera{
        position = rl.Vector3{1.0, 1.0, 1.0},
        target = rl.Vector3{0.0, 0.0, 0.0},
        up = rl.Vector3{0.0, 1.0, 0.0},
        fovy = 60.0,
        projection = rl.CameraProjection.PERSPECTIVE,
    }
    game_state.max_asteroids = 0
    game_state.update_frustum = true

    // Spawn player entity.
    player_entity := new(Entities.Entity)
    player_entity.shape = Entities.Model {}
    player_entity.logic = Entities.Player {}
    player_entity.transform.translation = rl.Vector3{Constants.WORLD_SIZE/2, Constants.WORLD_SIZE/2, Constants.WORLD_SIZE/2}
    player_entity.transform.rotation = rl.QuaternionFromEuler(0.0, 0.0, 0.0)
    player_entity.transform.scale = rl.Vector3{0.1, 0.0, 0.0}
    #partial switch &shape_model in player_entity.shape {
    case Entities.Model:
        shape_model.model = rl.LoadModel(Constants.SPACESHIP_MODEL)
        for i in 0..<shape_model.model.materialCount {
            shape_model.model.materials[i].shader = game_state.shader_lighting
        }
        bounding_box := rl.GetModelBoundingBox(shape_model.model)
        // Use smaller size for player.
        shape_model.size = rl.Vector3Distance(bounding_box.min, bounding_box.max) * player_entity.transform.scale.x * 0.5
    }
    append(&game_state.entities, player_entity)

    create_light(Entities.LightType.Directional, {0.0, 0.0, 0.0}, rl.Vector3Normalize({0.1, -1.0, 0.1}), rl.Color{255,255,255,255}, game_state.shader_lighting)
}

run_game :: proc(game_state: ^Entities.GameState) -> bool {
    // Clear background
    rl.ClearBackground(rl.BLACK)
    delta_time := rl.GetFrameTime()

    // Update UI data.
    switch &game_hud_state in game_state.menu_state.derived {
    case UI.GameHudState:
        // Update score.
        game_hud_state.score = game_state.score
        // Update time.
        if (!game_state.game_over) {
            game_hud_state.time = rl.GetTime() - game_state.start_time
        }
        // Update asteroids.
        game_hud_state.asteroids = get_num_asteroids(game_state)
        // Update game over.
        game_hud_state.game_over = game_state.game_over
    }

    // Run all game systems.
    if (!game_state.game_over) {
        system_player_fire_laser(game_state, delta_time)
        system_player_input(game_state, delta_time)

        system_update_movement(game_state, delta_time)

        system_asteroid_spawn(game_state, delta_time)
        system_laser_shot_update(game_state, delta_time)

        system_check_collisions(game_state, delta_time)
    }

    // Update camera.
    update_camera(game_state, delta_time)

    // Draw world.
    {
        rl.BeginMode3D(game_state.camera)
        defer rl.EndMode3D()

        update_light_values(game_state.shader_lighting, game_state.sun_light)

        update_frustum_from_camera(&game_state.camera, f32(game_state.screen_width)/f32(game_state.screen_height),
            &game_state.frustum, game_state)
        when (false) {
            draw_world_bounds(game_state)
        }
        draw_player(game_state)
        draw_asteroids(game_state)
        draw_laser_shots(game_state)
    }

    return true
}

close_game :: proc(game_state: ^Entities.GameState) {
    rl.EnableCursor()
    // Free all entities.
    for e in game_state.entities {
        free(e)
    }

    // Clear and shrink entities array (get rid of any memory allocated).
    clear(&game_state.entities)
    shrink(&game_state.entities, 0)
}

update_camera :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update camera rotation directly from mouse input.
    camera_rotation := rl.Vector3{0.0, 0.0, 0.0}
    camera_rotation.x = rl.GetMouseDelta().x * game_state.mouse_speed * 0.01
    camera_rotation.y = rl.GetMouseDelta().y * game_state.mouse_speed * 0.01
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

    // Draw 3x larger world bounds
    when (false) {
        num_iterations :: 3
        for x in -num_iterations..=num_iterations {
            for y in -num_iterations..=num_iterations {
                for z in -num_iterations..=num_iterations {
                    rl.DrawCubeWires(world_center + rl.Vector3{f32(x)*max_world_pos.x, f32(y)*max_world_pos.y, f32(z)*max_world_pos.z},
                    Constants.WORLD_SIZE, Constants.WORLD_SIZE, Constants.WORLD_SIZE, rl.BLUE)
                }
            }
        }
    }

    // Draw world bounds.
    rl.DrawCubeWires(world_center, max_world_pos.x, max_world_pos.y, max_world_pos.z, rl.RED)
}

vec2_to_string :: proc(text: cstring, v: rl.Vector2) -> cstring {
    return rl.TextFormat("%s(%.2f, %.2f)", text, v.x, v.y)
}

vec3_to_string :: proc(text: cstring, v: rl.Vector3) -> cstring {
    return rl.TextFormat("%s(%.2f, %.2f, %.2f)", text, v.x, v.y, v.z)
}

remove_entity_from_game_state :: proc(game_state: ^Entities.GameState, entity: ^Entities.Entity) {
    for e, i in game_state.entities {
        if (e == entity) {
            unordered_remove(&game_state.entities, i)
            free(e)
            return
        }
    }
    //fmt.eprintfln("Entity not found in game state.")
}

get_player_entity :: proc(game_state: ^Entities.GameState) -> ^Entities.Entity {
// Iterate all entities until correct one found.
    for e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.Player:
            return e
        }
    }
    return nil
}