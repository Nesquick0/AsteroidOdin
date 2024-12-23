#+vet !unused-imports
package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"
import "../Components"
import "core:fmt"

import "../tracy"

system_laser_shot_movement :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Update laser shot positions based on velocity.
    for &e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.LaserShot:
            e.transform.translation += e.velocity * delta_time
            // Loop laser shot position in world bounds.
            e.transform.translation = Constants.loop_position(e.transform.translation)

            // Update laser shot TTL.
            e_logic.time_to_live -= delta_time
            if e_logic.time_to_live <= 0.0 {
                // Delete laser shot.
                remove_entity_from_game_state(game_state, &e)
                continue
            }

            // Check if laser shot is colliding with an asteroid.
            if (check_laser_shot_collision(game_state, &e)) {
                remove_entity_from_game_state(game_state, &e)
                continue
            }
        }
    }
}

check_laser_shot_collision :: proc(game_state: ^Entities.GameState, laser_shot_entity: ^Entities.Entity) -> bool {
    // Check if laser shot is colliding with an asteroid.
    for &e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.Asteroid:
            hit := rl.CheckCollisionSpheres(laser_shot_entity.transform.translation, 1.0,
                e.transform.translation, e.shape.(Entities.Model).size/2)
            if (hit) {
                destroy_asteroid(game_state, &e)
                return true
            }
        }
    }
    return false
}

destroy_asteroid :: proc(game_state: ^Entities.GameState, asteroid_entity: ^Entities.Entity) {
    #partial switch &e_logic in asteroid_entity.logic {
    case Entities.Asteroid:
        switch e_logic.asteroid_type {
        case Components.AsteroidType.Small:
            game_state.score += 4
        case Components.AsteroidType.Medium:
            game_state.score += 2
        case Components.AsteroidType.Large:
            game_state.score += 1
        }
    }

    remove_entity_from_game_state(game_state, asteroid_entity)
}

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