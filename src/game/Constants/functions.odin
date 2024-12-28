package Constants

import rl "../../../raylib"
import "core:math"

loop_position :: proc(position: rl.Vector3) -> rl.Vector3 {
    new_position := position
    for i in 0..<3 {
        new_position[i] = math.mod_f32(new_position[i], WORLD_SIZE)
        if new_position[i] < 0.0 {
            new_position[i] -= WORLD_SIZE
            new_position[i] = math.mod_f32(new_position[i], WORLD_SIZE)
            new_position[i] += WORLD_SIZE
        }
    }
    return new_position
}