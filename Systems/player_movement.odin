#+vet !unused-imports
package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"

import "../tracy"

system_player_movement :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Get player entity.
    player_entity := get_player_entity(game_state)

    // Calculate player input vector.
    player_input := rl.Vector3{0.0, 0.0, 0.0}
    if rl.IsKeyDown(.W) {
        player_input.z += 1.0
    }
    if rl.IsKeyDown(.S) {
        player_input.z -= 1.0
    }
    if rl.IsKeyDown(.A) {
        player_input.x -= 1.0
    }
    if rl.IsKeyDown(.D) {
        player_input.x += 1.0
    }

    // Update player rotation based on camera angle.
    player_direction := rl.Vector3Normalize(game_state.camera.target - game_state.camera.position)
    player_right_dir := rl.Vector3CrossProduct(player_direction, rl.Vector3{0.0, 1.0, 0.0})

    player_direction *= player_input.z
    player_right_dir *= player_input.x

    // Update player velocity
    change_velocity := (player_direction + player_right_dir) * Constants.PLAYER_ACCELERATION * delta_time
    player_entity.velocity = player_entity.velocity + change_velocity
    // Limit velocity.
    velocity_dir := rl.Vector3Normalize(player_entity.velocity)
    velocity_size := rl.Vector3Length(player_entity.velocity)
    velocity_size = rl.Clamp(velocity_size, -Constants.PLAYER_MAX_SPEED, Constants.PLAYER_MAX_SPEED)
    player_entity.velocity = velocity_dir * velocity_size

    // Update player position
    player_entity.transform.translation += player_entity.velocity * delta_time

    // Loop player position in world bounds.
    player_entity.transform.translation = Constants.loop_position(player_entity.transform.translation)

    // Update player rotation.
    skip_rotation := rl.IsKeyDown(.LEFT_ALT)
    if (!skip_rotation)
    {
        player_entity.transform.rotation = rl.QuaternionFromEuler(0.0, -game_state.camera_angle.y, -game_state.camera_angle.x)
    }

    //rl.DrawText(vec3_to_string("Pos ", player_entity.transform.translation), 10, 40, 10, rl.WHITE)
    //rl.DrawText(vec3_to_string("Vel ", player_entity.velocity), 10, 50, 10, rl.WHITE)
}

get_player_entity :: proc(game_state: ^Entities.GameState) -> ^Entities.Player {
    // Iterate all entities until correct one found.
    for &e in game_state.entities {
        player_entity, e_ok := &e.derived.(Entities.Player)
        if e_ok {
            return player_entity
        }
    }
    return nil
}

get_player_model_matrix :: proc(player_entity: ^Entities.Player) -> rl.Matrix {
    rotation_matrix := rl.QuaternionToMatrix(player_entity.transform.rotation)
    rotation_matrix = rl.MatrixLookAt(
    rl.Vector3{0.0, 0.0, 0.0},
    rl.Vector3{0.0, 1.0, 0.0},
    rl.Vector3{0.0, 0.0, 1.0}) * rotation_matrix
    return rotation_matrix
}

draw_player :: proc(game_state: ^Entities.GameState) {
    when TRACY_ENABLE{
        tracy.Zone();
    }
    player_entity := get_player_entity(game_state)
    // Custom model transform.
    local_position_offset := rl.Vector3{-12.0, -3.0, -2.0}
    local_translation := rl.MatrixTranslate(local_position_offset.x, local_position_offset.y, local_position_offset.z)

    rotation_matrix := get_player_model_matrix(player_entity)

    // Rotate model.
    player_entity.model.transform = rotation_matrix * local_translation

    // Draw player model.
    //rl.DrawModel(player_entity.model, player_entity.transform.translation, player_entity.transform.scale.x, rl.WHITE)

    // TODO: Optimize to only draw objects in view frustum.
    // Draw repetition of actual world.
    num_iterations :: Constants.MAX_DRAW_ITERATIONS
    for x in -num_iterations..=num_iterations {
        for y in -num_iterations..=num_iterations {
            for z in -num_iterations..=num_iterations {
                rl.DrawModel(player_entity.model,
                    player_entity.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE},
                    player_entity.transform.scale.x, rl.WHITE)
            }
        }
    }

    // Draw debug sphere around player position.
    when (false) {
        model_bounds := rl.GetModelBoundingBox(player_entity.model)
        model_size := rl.Vector3Distance(model_bounds.min, model_bounds.max) * player_entity.transform.scale.x
        rl.DrawSphereWires(player_entity.transform.translation, model_size/2, 8, 8, rl.GREEN)
    }
    // Try to draw fire laser places.
    when (false)
    {
        world_positionL, world_dirL := get_laser_position(player_entity, Entities.WeaponId.Left)
        rl.DrawSphereWires(world_positionL, 0.1, 8, 8, rl.GREEN)
        world_positionR, world_dirR := get_laser_position(player_entity, Entities.WeaponId.Right)
        rl.DrawSphereWires(world_positionR, 0.1, 8, 8, rl.GREEN)
    }
}