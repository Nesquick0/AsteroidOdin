package UI

import rl "vendor:raylib"
import "core:fmt"

draw_game_hud :: proc(game_state: ^GameHudState, screen_width: i32, screen_height: i32) -> MenuTag {
    // Draw score in top right corner.
    score_text := rl.TextFormat("Score: %d", game_state.score)
    score_text_size := rl.MeasureText(score_text, 20)
    rl.DrawText(score_text, screen_width-10 - score_text_size, 10, 20, rl.WHITE)

    return MenuTag.GameMenu
}