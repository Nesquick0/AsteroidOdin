package UI

import rl "vendor:raylib"

draw_game_hud :: proc(game_state: ^GameHudState, screen_width: i32, screen_height: i32) -> MenuTag {
    score_text := rl.TextFormat("Score: %d", game_state.score)
    time_text := rl.TextFormat("Time: %.1f", game_state.time)
    asteroids_text := rl.TextFormat("Asteroids: %d", game_state.asteroids)

    // Draw score in top middle.
    score_text_size := rl.MeasureText(score_text, 20)
    rl.DrawText(score_text, screen_width/2 - score_text_size/2, 10, 20, rl.WHITE)
    // Draw time in top right corner.
    time_text_size := rl.MeasureText(time_text, 20)
    rl.DrawText(time_text, screen_width-10 - time_text_size, 10, 20, rl.WHITE)
    // Draw asteroids in top right corner.
    asteroids_text_size := rl.MeasureText(asteroids_text, 20)
    rl.DrawText(asteroids_text, screen_width-10 - asteroids_text_size, 40, 20, rl.WHITE)

    // Draw crosshairs in the center.
    middle_space : i32 = 5
    crosshair_size : i32 = 10
    rl.DrawLine(screen_width/2 + middle_space, screen_height/2, screen_width/2 + middle_space + crosshair_size, screen_height/2, rl.GREEN)
    rl.DrawLine(screen_width/2, screen_height/2 + middle_space, screen_width/2, screen_height/2 + middle_space + crosshair_size, rl.GREEN)
    rl.DrawLine(screen_width/2 - middle_space, screen_height/2, screen_width/2 - middle_space - crosshair_size, screen_height/2, rl.GREEN)
    rl.DrawLine(screen_width/2, screen_height/2 - middle_space, screen_width/2, screen_height/2 - middle_space - crosshair_size, rl.GREEN)

    return MenuTag.GameMenu
}