package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"

draw_player :: proc(game_state: ^Entities.GameState) {
    player_entity := get_player_entity(game_state)
    // Custom model transform.
    local_position_offset := rl.Vector3{-12.0, -3.0, -2.0}
    local_translation := rl.MatrixTranslate(local_position_offset.x, local_position_offset.y, local_position_offset.z)

    rotation_matrix := get_player_model_matrix(player_entity)

    // Rotate model.
    #partial switch &e_shape in player_entity.shape {
    case Entities.Model:
        e_shape.model.transform = rotation_matrix * local_translation

        // Draw player model.
        //rl.DrawModel(e_shape.model, player_entity.transform.translation, player_entity.transform.scale.x, rl.WHITE)

        // TODO: Optimize to only draw objects in view frustum.
        // Draw repetition of actual world.
        num_iterations :: Constants.MAX_DRAW_ITERATIONS
        for x in -num_iterations..=num_iterations {
            for y in -num_iterations..=num_iterations {
                for z in -num_iterations..=num_iterations {
                    rl.DrawModel(e_shape.model,
                    player_entity.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE},
                    player_entity.transform.scale.x, rl.WHITE)
                }
            }
        }

        // Draw debug sphere around player position.
        when (false) {
            model_bounds := rl.GetModelBoundingBox(player_entity.model)
            model_size := rl.Vector3Distance(model_bounds.min, model_bounds.max) * player_entity.transform.scale.x
            rl.DrawSphereWires(player_entity.transform.translation, model_size/2, 8, 8, rl.GREEN)
        }
    }
    // Try to draw fire laser places.
    when (false)
    {
        world_positionL, world_dirL := get_laser_position(player_entity, Entities.WeaponId.Left)
        rl.DrawSphereWires(world_positionL, 0.1, 8, 8, rl.GREEN)
        world_positionR, world_dirR := get_laser_position(player_entity, Entities.WeaponId.Right)
        rl.DrawSphereWires(world_positionR, 0.1, 8, 8, rl.GREEN)
    }
}