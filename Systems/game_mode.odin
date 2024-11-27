package Systems

import rl "vendor:raylib"
import "../Constants"
import "../Entities"
import "../UI"

start_game :: proc(game_state: ^Entities.GameState) {
    rl.DisableCursor()

    game_state.level_tag = Entities.LevelTag.GameLevel
    game_state.score = 0
    game_state.camera = rl.Camera{
        position = rl.Vector3{1.0, 1.0, 1.0},
        target = rl.Vector3{0.0, 0.0, 0.0},
        up = rl.Vector3{0.0, 1.0, 0.0},
        fovy = 60.0,
        projection = rl.CameraProjection.PERSPECTIVE,
    }
}

run :: proc(game_state: ^Entities.GameState) -> bool {
    // Clear background
    rl.ClearBackground(rl.BLACK)

    // Update UI data.
    switch &e in game_state.menu_state.derived {
    case UI.GameHudState:
        // Update score.
        game_hud_state := &e.derived.(UI.GameHudState)
        game_hud_state.score = game_state.score
    }

    // Update camera.
    //rl.UpdateCamera(&game_state.camera, rl.CameraMode.CUSTOM)
    camera_rotation := rl.Vector3{0.0, 0.0, 0.0}
    camera_rotation.x = rl.GetMouseDelta().x*0.1
    camera_rotation.y = rl.GetMouseDelta().y*0.1
    rl.UpdateCameraPro(&game_state.camera, rl.Vector3{0.0, 0.0, 0.0}, camera_rotation, 0.0)
    rl.BeginMode3D(game_state.camera)
    defer rl.EndMode3D()

    // Debug draw world bounds.
    min_world_pos := rl.Vector3{0.0, 0.0, 0.0}
    max_world_pos := rl.Vector3{Constants.WORLD_SIZE, Constants.WORLD_SIZE, Constants.WORLD_SIZE}
    rl.DrawCubeWires((max_world_pos - min_world_pos)/2, max_world_pos.x, max_world_pos.y, max_world_pos.z, rl.RED)
    //rl.DrawCube(rl.Vector3{0, 0, 0}, 1, 1, 1, rl.RED)

    // Run all game systems.

    return true
}