package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"

import "../tracy"

system_laser_shot_movement :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update laser shot positions based on velocity.
    for &e, i in game_state.entities {
        switch &e_derived in e.derived {
        case Entities.LaserShot:
            laser_shot_entity := &e.derived.(Entities.LaserShot)
            laser_shot_entity.transform.translation += laser_shot_entity.velocity * delta_time
            // Loop laser shot position in world bounds.
            laser_shot_entity.transform.translation = Constants.loop_position(laser_shot_entity.transform.translation)

            // Update laser shot TTL.
            laser_shot_entity.time_to_live -= delta_time
            if laser_shot_entity.time_to_live <= 0.0 {
                // Delete laser shot.
                unordered_remove(&game_state.entities, i)
                free(&e_derived)
            }
        }
    }
}

draw_laser_shots :: proc(game_state: ^Entities.GameState) {
    when TRACY_ENABLE{
        tracy.Zone();
    }
    // Draw laser shots.
    for &e in game_state.entities {
        switch &e_derived in e.derived {
        case Entities.LaserShot:
            laser_shot_entity := &e.derived.(Entities.LaserShot)

            // Draw laser shot as line for now.
            //rl.DrawLine3D(laser_shot_entity.transform.translation, laser_shot_entity.transform.translation + laser_shot_entity.velocity, rl.GREEN)

            // TODO: Optimize to only draw objects in view frustum.
            // Draw repetition of actual world.
            num_iterations :: 2
            for x in -num_iterations..=num_iterations {
                for y in -num_iterations..=num_iterations {
                    for z in -num_iterations..=num_iterations {
                        start_pos := laser_shot_entity.transform.translation + rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                        end_pos := laser_shot_entity.transform.translation + (rl.Vector3Normalize(laser_shot_entity.velocity)*Constants.WORLD_SIZE*0.02) +
                            rl.Vector3{f32(x)*Constants.WORLD_SIZE, f32(y)*Constants.WORLD_SIZE, f32(z)*Constants.WORLD_SIZE}
                        //rl.DrawLine3D(start_pos, end_pos, rl.GREEN)
                        rl.DrawCylinderEx(start_pos, end_pos, 0.1, 0.1, 6, rl.GREEN)
                    }
                }
            }
        }
    }
}