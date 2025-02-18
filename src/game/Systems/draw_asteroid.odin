#+vet !unused-imports
package Systems

import rl "../../../raylib"
import "../Entities"
import "../Constants"

draw_asteroids :: proc(game_state: ^Entities.GameState) {
    // Draw asteroids.
    for &e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.Asteroid:
            asteroid_entity_shape := &e.shape.(Entities.Model)
            // Custom model transform.
            local_position_offset := rl.Vector3{0.0, 0.0, 0.0}
            local_translation := rl.MatrixTranslate(local_position_offset.x, local_position_offset.y, local_position_offset.z)

            rotation_matrix := rl.QuaternionToMatrix(e.transform.rotation)
            rotation_matrix = rl.MatrixLookAt(
            rl.Vector3{0.0, 0.0, 0.0},
            rl.Vector3{0.0, 1.0, 0.0},
            rl.Vector3{0.0, 0.0, 1.0}) * rotation_matrix

            // Rotate model.
            asteroid_entity_shape.model.transform = rotation_matrix * local_translation

            // Draw repetition of actual world.
            num_iterations :: Constants.MAX_DRAW_ITERATIONS
            for x in -num_iterations..=num_iterations {
                for y in -num_iterations..=num_iterations {
                    for z in -num_iterations..=num_iterations {
                        draw_pos := e.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                        should_draw := sphere_in_frustum(&game_state.frustum, draw_pos, asteroid_entity_shape.size)
                        if (should_draw) {
                            rl.DrawModel(asteroid_entity_shape.model, draw_pos, e.transform.scale.x, rl.WHITE)
                        }
                    }
                }
            }

            // Draw debug sphere around asteroid position.
            when (false) {
                rl.DrawSphereWires(e.transform.translation, asteroid_entity_shape.size/2, 8, 8, rl.GREEN)
            }
        }
    }
}