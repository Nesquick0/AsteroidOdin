﻿package Systems

import rl "../../../raylib"
import "../Entities"
import "../Constants"
import "../Components"

system_player_fire_laser :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Get player entity.
    player_entity := get_player_entity(game_state)
    player_entity_logic := &player_entity.logic.(Entities.Player)

    // Update reload countdown.
    player_entity_logic.reload_countdown -= delta_time
    if player_entity_logic.reload_countdown <= 0.0 {
        player_entity_logic.reload_countdown = 0.0
    }

    // Check if player is firing laser.
    if rl.IsMouseButtonDown(.LEFT) && player_entity_logic.reload_countdown <= 0.0 {
        // Fire and reset reload countdown.
        player_entity_logic.reload_countdown = Constants.PLAYER_LASER_RELOAD_TIME
        // Swap weapon id.
        #partial switch player_entity_logic.weapon_id {
        case Components.WeaponId.Left:
            player_entity_logic.weapon_id = Components.WeaponId.Right
        case Components.WeaponId.Right:
            player_entity_logic.weapon_id = Components.WeaponId.Left
        }

        // Get laster start position.
        laser_start_pos, laser_start_dir := get_laser_position(player_entity, player_entity_logic.weapon_id)
        new_laser := spawn_laser(game_state, laser_start_pos, laser_start_dir)
        #partial switch &e_logic in new_laser.logic {
        case Entities.LaserShot:
            e_logic.time_to_live = Constants.LASER_SHOT_TTL
        }
        new_laser.velocity = (laser_start_dir * Constants.LASER_SHOT_VELOCITY) + player_entity.velocity
    }
}

get_laser_position :: proc(player_entity: ^Entities.Entity, weapon_id: Components.WeaponId) -> (rl.Vector3, rl.Vector3) {
    // Get player position.
    player_position := player_entity.transform.translation
    // Get player direction.
    player_direction := rl.Vector3Transform(rl.Vector3{1.0, 0.0, 0.0}, get_player_model_matrix(player_entity))

    // Get player matrix.
    player_matrix := rl.MatrixLookAt(player_position,  player_position + player_direction, rl.Vector3{0.0, 1.0, 0.0})

    // Get laser position.
    local_position_offset := rl.Vector3{0.0, 0.0, 0.0}
    #partial switch weapon_id {
    case Components.WeaponId.Left:
        local_position_offset = rl.Vector3{-4.0, 0.0, -8.0} * player_entity.transform.scale.x
    case Components.WeaponId.Right:
        local_position_offset = rl.Vector3{4.0, 0.0, -8.0} * player_entity.transform.scale.x
    }

    world_position := rl.Vector3Transform(local_position_offset, rl.MatrixInvert(player_matrix))

    return world_position, player_direction
}

spawn_laser :: proc(game_state: ^Entities.GameState, start_pos: rl.Vector3, start_dir: rl.Vector3) -> ^Entities.Entity {
    laser_entity := new(Entities.Entity)
    laser_entity.shape = Entities.SimpleLine {}
    laser_entity.logic = Entities.LaserShot {}
    laser_entity.transform.translation = start_pos
    laser_entity.transform.rotation = rl.QuaternionFromEuler(0.0, 0.0, 0.0)
    laser_entity.transform.scale = rl.Vector3{1.0, 0.0, 0.0}
    append(&game_state.entities, laser_entity)
    return game_state.entities[len(game_state.entities)-1]
}