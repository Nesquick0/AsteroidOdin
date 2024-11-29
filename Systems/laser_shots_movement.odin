package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"

system_laser_shot_movement :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update laser shot positions based on velocity.
    for &e in game_state.entities {
        switch &e_derived in e.derived {
        case Entities.LaserShot:
            laser_shot_entity := &e.derived.(Entities.LaserShot)
            laser_shot_entity.transform.translation += laser_shot_entity.velocity * delta_time
            // Loop laser shot position in world bounds.
            laser_shot_entity.transform.translation = Constants.loop_position(laser_shot_entity.transform.translation)
        }
    }
}

draw_laser_shots :: proc(game_state: ^Entities.GameState) {
    // Draw laser shots.
    for &e in game_state.entities {
        switch &e_derived in e.derived {
        case Entities.LaserShot:
            laser_shot_entity := &e.derived.(Entities.LaserShot)
            // Custom model transform.
            local_position_offset := rl.Vector3{0.0, 0.0, 0.0}
            local_translation := rl.MatrixTranslate(local_position_offset.x, local_position_offset.y, local_position_offset.z)

            rotation_matrix := rl.QuaternionToMatrix(laser_shot_entity.transform.rotation)
            rotation_matrix = rl.MatrixLookAt(
            rl.Vector3{0.0, 0.0, 0.0},
            rl.Vector3{0.0, 1.0, 0.0},
            rl.Vector3{0.0, 0.0, 1.0}) * rotation_matrix

            // Rotate model.
            laser_shot_entity.model.transform = rotation_matrix * local_translation

            // Draw laser shot model.
            rl.DrawModel(laser_shot_entity.model, laser_shot_entity.transform.translation, laser_shot_entity.transform.scale.x, rl.WHITE)

            // Draw debug sphere around player position.
            when (false) {
                model_bounds := rl.GetModelBoundingBox(laser_shot_entity.model)
                model_size := rl.Vector3Distance(model_bounds.min, model_bounds.max) * laser_shot_entity.transform.scale.x
                rl.DrawSphereWires(laser_shot_entity.transform.translation, model_size/2, 8, 8, rl.GREEN)
            }
        }
    }
}