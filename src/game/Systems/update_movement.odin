package Systems

import "../Entities"
import "../Constants"

system_update_movement :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update position of all entities based on velocity.
    for &e in game_state.entities {
        e.transform.translation += e.velocity * delta_time
        // Loop asteroid position in world bounds.
        e.transform.translation = Constants.loop_position(e.transform.translation)
    }
}
