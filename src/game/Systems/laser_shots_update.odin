package Systems

import "../Entities"

system_laser_shot_update :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update laser shot positions based on velocity.
    for e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.LaserShot:
            // Update laser shot TTL.
            e_logic.time_to_live -= delta_time
            if e_logic.time_to_live <= 0.0 {
                // Delete laser shot.
                remove_entity_from_game_state(game_state, e)
                continue
            }
        }
    }
}

