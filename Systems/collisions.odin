package Systems

import rl "vendor:raylib"

import "../Entities"
import "../Components"

system_check_collisions :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Get player entity.
    player_entity := get_player_entity(game_state)

    for &e in game_state.entities {
        switch &e_logic in e.logic {
            case Entities.Player:
            case Entities.LaserShot:
                check_laser_shot_collision(game_state, &e)
            case Entities.Asteroid:
                check_asteroid_collision(game_state, player_entity, &e)
        }
    }
}

check_asteroid_collision :: proc(game_state: ^Entities.GameState,
player_entity: ^Entities.Entity, asteroid_entity: ^Entities.Entity) -> bool {
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