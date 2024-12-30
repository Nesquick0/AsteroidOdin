package Systems

import rl "../../../raylib"
import "../Entities"
import "../Constants"

system_player_input :: proc(game_state: ^Entities.GameState, delta_time: f32) {
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

    // Update player rotation.
    skip_rotation := rl.IsKeyDown(.LEFT_ALT)
    if (!skip_rotation) {
        //player_entity.transform.rotation = rl.QuaternionFromEuler(0.0, -game_state.camera_angle.x, game_state.camera_angle.y)
        player_entity.transform.rotation = rl.QuaternionFromAxisAngle(rl.Vector3{0.0, 1.0, 0.0}, -game_state.camera_angle.x) // Rotate around Y axis (up)
        player_entity.transform.rotation *= rl.QuaternionFromAxisAngle(rl.Vector3{0.0, 0.0, 1.0}, game_state.camera_angle.y) // Rotate around Z axis (right)
        player_entity.transform.rotation = rl.QuaternionNormalize(player_entity.transform.rotation)
    }

    //rl.DrawText(vec3_to_string("Pos ", player_entity.transform.translation), 10, 40, 10, rl.WHITE)
    //rl.DrawText(vec3_to_string("Vel ", player_entity.velocity), 10, 50, 10, rl.WHITE)
}
