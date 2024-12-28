#+vet !unused-imports
package Systems

import rl "../../../raylib"
import "../Entities"
import "../Constants"

draw_laser_shots :: proc(game_state: ^Entities.GameState) {
    // Get player entity.
    player_entity := get_player_entity(game_state)
    player_position := player_entity.transform.translation

    laser_shot_size :: Constants.WORLD_SIZE*0.02

    // Draw laser shots.
    for &e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.LaserShot:
            // Draw laser shot as line for now.
            //rl.DrawLine3D(e.transform.translation, e.transform.translation + e.velocity, rl.GREEN)

            // Draw repetition of actual world.
            num_iterations :: Constants.MAX_DRAW_ITERATIONS
            for x in -num_iterations..=num_iterations {
                for y in -num_iterations..=num_iterations {
                    for z in -num_iterations..=num_iterations {
                        start_pos := e.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                        should_draw := point_in_frustum(&game_state.frustum, start_pos)
                        if (should_draw) {
                            from_player_dir := rl.Vector3Normalize(start_pos - player_position)
                            end_pos := e.transform.translation + (from_player_dir*laser_shot_size) +
                                rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                            //rl.DrawLine3D(start_pos, end_pos, rl.GREEN)
                            rl.DrawCylinderEx(start_pos, end_pos, 0.1, 0.1, 6, rl.GREEN)
                        }
                    }
                }
            }
        }
    }
}