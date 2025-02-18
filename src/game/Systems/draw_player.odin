﻿package Systems

import rl "../../../raylib"
import "../Entities"
import "../Constants"

draw_player :: proc(game_state: ^Entities.GameState) {
    player_entity := get_player_entity(game_state)
    // Custom model transform.
    local_position_offset := rl.Vector3{-12.0, -3.0, 3.0}
    local_translation := rl.MatrixTranslate(local_position_offset.x, local_position_offset.y, local_position_offset.z)

    rotation_matrix := get_player_model_matrix(player_entity)

    // Rotate model.
    #partial switch &e_shape in player_entity.shape {
    case Entities.Model:
        e_shape.model.transform = rotation_matrix * local_translation

        // Draw player model.
        //rl.DrawModel(e_shape.model, player_entity.transform.translation, player_entity.transform.scale.x, rl.WHITE)

        // Draw repetition of actual world.
        num_iterations :: Constants.MAX_DRAW_ITERATIONS
        for x in -num_iterations..=num_iterations {
            for y in -num_iterations..=num_iterations {
                for z in -num_iterations..=num_iterations {
                    draw_pos := player_entity.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                    should_draw := point_in_frustum(&game_state.frustum, draw_pos)
                    if (should_draw) {
                        rl.DrawModel(e_shape.model, draw_pos, player_entity.transform.scale.x, rl.WHITE)
                    }
                }
            }
        }

        // Draw debug sphere around player position.
        when (false) {
            model_bounds := rl.GetModelBoundingBox(e_shape.model)
            model_size := rl.Vector3Distance(model_bounds.min, model_bounds.max) * player_entity.transform.scale.x
            rl.DrawSphereWires(player_entity.transform.translation, model_size/2, 8, 8, rl.GREEN)
        }
        // Draw debug lines for each axis.
        when (false) {
            rl.DrawLine3D(player_entity.transform.translation, player_entity.transform.translation + rl.Vector3{100.0, 0.0, 0.0}, rl.GREEN) //X
            rl.DrawLine3D(player_entity.transform.translation, player_entity.transform.translation + rl.Vector3{0.0, 100.0, 0.0}, rl.RED)   //Y
            rl.DrawLine3D(player_entity.transform.translation, player_entity.transform.translation + rl.Vector3{0.0, 0.0, 100.0}, rl.BLUE)  //Z

            // Draw forward direction of player model.
            rl.DrawLine3D(player_entity.transform.translation, player_entity.transform.translation + rl.Vector3RotateByQuaternion(rl.Vector3{100.0, 0.0, 0.0}, player_entity.transform.rotation), rl.ORANGE)
        }
    }
    // Try to draw fire laser places.
    when (false) {
        world_positionL, world_dirL := get_laser_position(player_entity, Entities.WeaponId.Left)
        rl.DrawSphereWires(world_positionL, 0.1, 8, 8, rl.GREEN)
        world_positionR, world_dirR := get_laser_position(player_entity, Entities.WeaponId.Right)
        rl.DrawSphereWires(world_positionR, 0.1, 8, 8, rl.GREEN)
    }
}

get_player_model_matrix :: proc(player_entity: ^Entities.Entity) -> rl.Matrix {
    rotation_matrix := rl.QuaternionToMatrix(player_entity.transform.rotation)
//    rotation_matrix = rl.MatrixLookAt(
//        rl.Vector3{0.0, 0.0, 0.0}, /*eye*/
//        rl.Vector3{0.0, 0.0, -1.0},/*target*/
//        rl.Vector3{0.0, 1.0, 0.0}  /*up*/ ) * rotation_matrix
    return rotation_matrix
}
