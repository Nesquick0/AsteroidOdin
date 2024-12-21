package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"

import "../tracy"

system_asteroid_movement :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update asteroid positions based on velocity.
    for &e in game_state.entities {
        asteroid_entity, e_ok := &e.derived.(Entities.Asteroid)
        if e_ok {
            asteroid_entity.transform.translation += asteroid_entity.velocity * delta_time
            // Loop asteroid position in world bounds.
            asteroid_entity.transform.translation = Constants.loop_position(asteroid_entity.transform.translation)
        }
    }
}

draw_asteroids :: proc(game_state: ^Entities.GameState) {
    when TRACY_ENABLE{
        tracy.Zone();
    }
    // Draw asteroids.
    for &e in game_state.entities {
        asteroid_entity, e_ok := &e.derived.(Entities.Asteroid)
        if e_ok {
            // Custom model transform.
            local_position_offset := rl.Vector3{0.0, 0.0, 0.0}
            local_translation := rl.MatrixTranslate(local_position_offset.x, local_position_offset.y, local_position_offset.z)

            rotation_matrix := rl.QuaternionToMatrix(asteroid_entity.transform.rotation)
            rotation_matrix = rl.MatrixLookAt(
            rl.Vector3{0.0, 0.0, 0.0},
            rl.Vector3{0.0, 1.0, 0.0},
            rl.Vector3{0.0, 0.0, 1.0}) * rotation_matrix

            // Rotate model.
            asteroid_entity.model.transform = rotation_matrix * local_translation

            // Draw asteroid model.
            //rl.DrawModel(asteroid_entity.model, asteroid_entity.transform.translation, asteroid_entity.transform.scale.x, rl.WHITE)

            // TODO: Optimize to only draw objects in view frustum.
            // Draw repetition of actual world.
            num_iterations :: 2
            for x in -num_iterations..=num_iterations {
                for y in -num_iterations..=num_iterations {
                    for z in -num_iterations..=num_iterations {
                        rl.DrawModel(asteroid_entity.model,
                            asteroid_entity.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE},
                            asteroid_entity.transform.scale.x, rl.WHITE if (x == 0 && y == 0 && z == 0) else rl.WHITE)
                    }
                }
            }

            // Draw debug sphere around asteroid position.
            when (false) {
                model_bounds := rl.GetModelBoundingBox(asteroid_entity.model)
                model_size := rl.Vector3Distance(model_bounds.min, model_bounds.max) * asteroid_entity.transform.scale.x
                rl.DrawSphereWires(asteroid_entity.transform.translation, model_size/2, 8, 8, rl.GREEN)
            }
        }
    }
}