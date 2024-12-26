package Systems

import rl "vendor:raylib"
import "../Entities"
import "../Constants"
import "../Components"

system_asteroid_spawn :: proc(game_state: ^Entities.GameState, delta_time: f32) {
    // Increase number of asteroids with time.
    game_time := rl.GetTime() - game_state.start_time
    game_state.max_asteroids = Constants.INITIAL_ASTEROID_COUNT + i32(game_time/Constants.ASTEROID_INCREASE_TIME)

    // Count asteriods. Spawn new if necessary.
    num_asteroids := get_num_asteroids(game_state)
    if num_asteroids < game_state.max_asteroids {
        // Spawn new asteroid far from player

        // Get player position.
        player_entity := get_player_entity(game_state)
        player_position := player_entity.transform.translation

        // Get random direction in distance half of world size.
        random_direction := get_random_vec3_normalized()
        random_direction = random_direction * Constants.WORLD_SIZE/2

        // Get random position in random direction.
        random_position := player_position + random_direction
        random_position = Constants.loop_position(random_position)

        // Random velocity.
        random_velocity := get_random_vec3_normalized()
        max_initial_velocity := Constants.WORLD_SIZE/10
        random_velocity = random_velocity * f32(rl.GetRandomValue(i32(max_initial_velocity/2), i32(max_initial_velocity)))

        // Spawn asteroid.
        asteroid_entity := spawn_asteroid_at_location(game_state, random_position, Components.AsteroidType.Large)
        asteroid_entity.velocity = random_velocity
    }
}

get_num_asteroids :: proc(game_state: ^Entities.GameState) -> i32 {
    // Iterate all entities until correct one found.
    num_asteroids : i32 = 0
    for &e in game_state.entities {
        #partial switch &e_logic in e.logic {
        case Entities.Asteroid:
            num_asteroids += 1
        }
    }
    return num_asteroids
}

spawn_asteroid_at_location :: proc(game_state: ^Entities.GameState, location: rl.Vector3,
    asteroid_type: Components.AsteroidType) -> ^Entities.Entity {
    asteroid_entity := new(Entities.Entity)
    asteroid_entity.shape = Entities.Model {}
    asteroid_entity.logic = Entities.Asteroid {}
    asteroid_entity.transform.translation = location
    asteroid_entity.transform.rotation = rl.QuaternionFromEuler(0.0, 0.0, 0.0)
    asteroid_entity.transform.scale = rl.Vector3{1.0, 0.0, 0.0}

    #partial switch &e_logic in asteroid_entity.logic {
    case Entities.Asteroid:
        e_logic.asteroid_type = asteroid_type
        asteroid_entity.transform.scale = rl.Vector3{Components.get_asteroid_size(e_logic.asteroid_type), 0.0, 0.0}
    }

    #partial switch &e_shape in asteroid_entity.shape {
    case Entities.Model:
        e_shape.model = rl.LoadModel(Constants.ASTEROID_MODEL)
        for i in 0..<e_shape.model.materialCount {
            e_shape.model.materials[i].shader = game_state.shader_lighting
        }

        bounding_box := rl.GetModelBoundingBox(e_shape.model)
        // Use smaller size for player.
        e_shape.size = rl.Vector3Distance(bounding_box.min, bounding_box.max) * asteroid_entity.transform.scale.x *
            Constants.ASTEROID_COLLISION_SCALE
    }

    append(&game_state.entities, asteroid_entity)
    return game_state.entities[len(game_state.entities)-1]
}

get_random_vec3_normalized :: proc() -> rl.Vector3 {
    random_direction := rl.Vector3{f32(rl.GetRandomValue(-100, 100)), f32(rl.GetRandomValue(-100, 100)), f32(rl.GetRandomValue(-100, 100))}
    if (rl.Vector3LengthSqr(random_direction) < 1.0) {
        random_direction[0] = 1.0
    }
    random_direction = rl.Vector3Normalize(random_direction)

    return random_direction
}