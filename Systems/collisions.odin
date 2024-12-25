package Systems

import rl "vendor:raylib"

import "../Entities"
import "../Components"

system_check_collisions :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Get player entity.
    player_entity := get_player_entity(game_state)

    for e in game_state.entities {
        switch &e_logic in e.logic {
            case Entities.Player:
            case Entities.LaserShot:
                check_laser_shot_collision(game_state, e)
            case Entities.Asteroid:
                check_asteroid_collision(game_state, e, player_entity)
        }
    }
}

check_asteroid_collision :: proc(game_state: ^Entities.GameState,
    asteroid_entity: ^Entities.Entity, player_entity: ^Entities.Entity) -> bool {

    // Check if any asteroid collides with player.
    hit := rl.CheckCollisionSpheres(player_entity.transform.translation,
        player_entity.shape.(Entities.Model).size / 2,
        asteroid_entity.transform.translation, asteroid_entity.shape.(Entities.Model).size / 2)
    if (hit) {
        game_state.game_over = true
        return true
    }
    return false
}

check_laser_shot_collision :: proc(game_state: ^Entities.GameState, laser_shot_entity: ^Entities.Entity) -> bool {
    // Check if laser shot is colliding with an asteroid.
    for e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.Asteroid:
            hit := rl.CheckCollisionSpheres(laser_shot_entity.transform.translation, 1.0,
                e.transform.translation, e.shape.(Entities.Model).size / 2)
            if (hit) {
                // Remove laser shot.
                remove_entity_from_game_state(game_state, laser_shot_entity)
                // Destroy asteroid.
                destroy_asteroid(game_state, e)
                return true
            }
        }
    }
    return false
}

destroy_asteroid :: proc(game_state: ^Entities.GameState, asteroid_entity: ^Entities.Entity) {
    asteroid_transform := asteroid_entity.transform
    asteroid_velocity := asteroid_entity.velocity

    #partial switch &e_logic in asteroid_entity.logic {
    case Entities.Asteroid:
        switch e_logic.asteroid_type {
        case Components.AsteroidType.Small:
            game_state.score += 4
            // Smallest asteroid, don't spawn anything.
        case Components.AsteroidType.Medium:
            game_state.score += 2
            // Spawn 2 small asteroids.
            asteroid1 := spawn_asteroid_at_location(game_state,
                asteroid_transform.translation, Components.AsteroidType.Small)
            asteroid2 := spawn_asteroid_at_location(game_state,
                asteroid_transform.translation, Components.AsteroidType.Small)
            // Set new velocity.
            set_new_asteroid_velocity(asteroid1, asteroid2, asteroid_velocity)
        case Components.AsteroidType.Large:
            game_state.score += 1
            // Spawn 2 medium asteroids.
            asteroid1 := spawn_asteroid_at_location(game_state,
                asteroid_transform.translation, Components.AsteroidType.Medium)
            asteroid2 := spawn_asteroid_at_location(game_state,
                asteroid_transform.translation, Components.AsteroidType.Medium)
            // Set new velocity.
            set_new_asteroid_velocity(asteroid1, asteroid2, asteroid_velocity)
        }
    }

    remove_entity_from_game_state(game_state, asteroid_entity)
}

set_new_asteroid_velocity :: proc(asteroid1, asteroid2: ^Entities.Entity, old_velocity: rl.Vector3) {
    old_velocity_norm := rl.Vector3Normalize(old_velocity)
    random_direction := get_random_vec3_normalized()
    old_velocity_size := rl.Vector3Length(old_velocity)

    // Calculate perpendicular velocity.
    perp_velocity := rl.Vector3CrossProduct(old_velocity_norm, random_direction)

    // Normalize perp_velocity and old_velocity.
    perp_velocity_norm := rl.Vector3Normalize(perp_velocity)

    // Calculate new velocity.
    new_velocity1 := rl.Vector3Normalize(2*old_velocity_norm + perp_velocity_norm) * old_velocity_size
    asteroid1.velocity = new_velocity1
    new_velocity2 := rl.Vector3Normalize(2*old_velocity_norm - perp_velocity_norm) * old_velocity_size
    asteroid2.velocity = new_velocity2
}