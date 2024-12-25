#+vet !unused-imports
package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"

import "../tracy"

draw_laser_shots :: proc(game_state: ^Entities.GameState) {
    when TRACY_ENABLE{
        tracy.Zone();
    }
    // Draw laser shots.
    for &e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.LaserShot:
        // Draw laser shot as line for now.
        //rl.DrawLine3D(e.transform.translation, e.transform.translation + e.velocity, rl.GREEN)

        // TODO: Optimize to only draw objects in view frustum.
        // Draw repetition of actual world.
            num_iterations :: Constants.MAX_DRAW_ITERATIONS
            for x in -num_iterations..=num_iterations {
                for y in -num_iterations..=num_iterations {
                    for z in -num_iterations..=num_iterations {
                        start_pos := e.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                        end_pos := e.transform.translation + (rl.Vector3Normalize(e.velocity)*Constants.WORLD_SIZE*0.02) +
                        rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                        //rl.DrawLine3D(start_pos, end_pos, rl.GREEN)
                        rl.DrawCylinderEx(start_pos, end_pos, 0.1, 0.1, 6, rl.GREEN)
                    }
                }
            }
        }
    }
}