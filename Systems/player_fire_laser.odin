﻿package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"

system_player_fire_laser :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Get player entity.
    player_entity := get_player_entity(game_state)

    // Update reload countdown.
    player_entity.reload_countdown -= delta_time
    if player_entity.reload_countdown <= 0.0 {
        player_entity.reload_countdown = 0.0
    }

    // Check if player is firing laser.
    if rl.IsMouseButtonDown(.LEFT) && player_entity.reload_countdown <= 0.0 {
        // Fire and reset reload countdown.
        player_entity.reload_countdown = Constants.PLAYER_LASER_RELOAD_TIME
        // Swap weapon id.
        #partial switch player_entity.weapon_id {
        case Entities.WeaponId.Left:
            player_entity.weapon_id = Entities.WeaponId.Right
        case Entities.WeaponId.Right:
            player_entity.weapon_id = Entities.WeaponId.Left
        }

        // Get laster start position.
        laser_start_pos, laser_start_dir := get_laser_position(player_entity, player_entity.weapon_id)
        new_laser := spawn_laser(game_state, laser_start_pos, laser_start_dir)
        new_laser.time_to_live = Constants.LASER_SHOT_TTL
        new_laser.velocity = (laser_start_dir * Constants.LASER_SHOT_VELOCITY) + player_entity.velocity
    }
}

get_laser_position :: proc(player_entity: ^Entities.Player, weapon_id: Entities.WeaponId) -> (rl.Vector3, rl.Vector3) {
    // Get player position.
    player_position := player_entity.transform.translation

    // Get player direction.
    player_direction := rl.Vector3Transform(rl.Vector3{1.0, 0.0, 0.0}, get_player_model_matrix(player_entity))

    // Get player matrix.
    player_matrix := rl.MatrixLookAt(player_entity.transform.translation,
        player_entity.transform.translation + player_direction, rl.Vector3{0.0, 1.0, 0.0})

    // Get laser position.
    local_position_offset := rl.Vector3{0.0, 0.0, 0.0}
    #partial switch weapon_id {
    case Entities.WeaponId.Left:
        local_position_offset = rl.Vector3{-4.0, 0.0, -8.0} * player_entity.transform.scale.x
    case Entities.WeaponId.Right:
        local_position_offset = rl.Vector3{4.0, 0.0, -8.0} * player_entity.transform.scale.x
    }

    world_position := rl.Vector3Transform(local_position_offset, rl.MatrixInvert(player_matrix))

    return world_position, player_direction
}

spawn_laser :: proc(game_state: ^Entities.GameState, start_pos: rl.Vector3, start_dir: rl.Vector3) -> ^Entities.LaserShot {
    new_entity := Entities.new_entity(Entities.LaserShot)
    laser_entity := &new_entity.derived.(Entities.LaserShot)
    laser_entity.transform.translation = start_pos
    laser_entity.transform.rotation = rl.QuaternionFromEuler(0.0, 0.0, 0.0)
    laser_entity.transform.scale = rl.Vector3{1.0, 0.0, 0.0}
    //laser_entity.model = rl.LoadModel("Data/laser_gltf/scene.gltf")
    append(&game_state.entities, laser_entity)
    return laser_entity
}