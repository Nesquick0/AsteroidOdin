package UI

import rl "vendor:raylib"

draw_main_menu :: proc(main_menu_state: ^MainMenuState, screen_width: i32, screen_height: i32) -> MenuTag {
    // Clear background
    rl.ClearBackground(rl.BLACK)

    // Get mouse position
    mouse_position := rl.GetMousePosition()

    // Define buttons positions.
    buttons_step : f32 = 60
    buttons_positions := [i32(MenuButton.Count)]MenuButtonWithText{
        {"Start game", rl.Rectangle{f32(screen_width)/2, f32(screen_height)/2+1*buttons_step, 0, 0}},
        {"Options", rl.Rectangle{f32(screen_width)/2, f32(screen_height)/2+2*buttons_step, 0, 0}},
        {"Exit", rl.Rectangle{f32(screen_width)/2, f32(screen_height)/2+3*buttons_step, 0, 0}},
    }
    // Update buttons size.
    for i in 0..<i32(MenuButton.Count) {
        buttons_positions[i].rect.width = f32(rl.MeasureText(buttons_positions[i].text, 50))
        buttons_positions[i].rect.x = f32(buttons_positions[i].rect.x) - buttons_positions[i].rect.width/2
        buttons_positions[i].rect.height = 50
    }

    // Check keyboard input
    if rl.IsKeyPressed(.UP) {
        main_menu_state.selected_button = MenuButton((i32(main_menu_state.selected_button) - 1) % i32(MenuButton.Count))
    }
    if rl.IsKeyPressed(.DOWN) {
        main_menu_state.selected_button = MenuButton((i32(main_menu_state.selected_button) + 1) % i32(MenuButton.Count))
    }

    for i in 0..<i32(MenuButton.Count) {
        if rl.CheckCollisionPointRec(mouse_position, buttons_positions[i].rect) {
            main_menu_state.selected_button = MenuButton(i)
        }
    }

    // Button activation.
    button_pressed := rl.IsKeyPressed(.ENTER) || rl.IsMouseButtonPressed(.LEFT)
    if button_pressed {
        #partial switch main_menu_state.selected_button {
            case MenuButton.StartGame:
                return MenuTag.GameMenu
            case MenuButton.Options:
                return MenuTag.OptionsMenu
            case MenuButton.Exit:
                return MenuTag.ExitGame
        }
    }

    // Draw title.
    title_str : cstring = "ODIN ASTEROIDS"
    title_size := rl.MeasureText(title_str, 50)
    rl.DrawText(title_str, screen_width/2 - title_size, screen_height/2-200, 100, rl.WHITE)

    // Draw buttons.
    for i in 0..<i32(MenuButton.Count) {
        button_color := rl.WHITE
        if main_menu_state.selected_button == MenuButton(i) {
            button_color = rl.RED
            rl.DrawRectangleRec(buttons_positions[i].rect, button_color)
        }
        rl.DrawText(buttons_positions[i].text, i32(buttons_positions[i].rect.x), i32(buttons_positions[i].rect.y), 50, rl.WHITE)
    }

    return MenuTag.MainMenu
}