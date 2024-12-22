package UI

import rl "vendor:raylib"

draw_options_menu :: proc(options_menu_state: ^OptionsMenuState, screen_width: i32, screen_height: i32) -> MenuTag {
    // Clear background
    rl.ClearBackground(rl.BLACK)

    // Get mouse position
    mouse_position := rl.GetMousePosition()

    // Draw title.
    title_str : cstring = "OPTIONS"
    title_size := rl.MeasureText(title_str, 50)
    rl.DrawText(title_str, screen_width/2 - title_size, screen_height/2-200, 100, rl.WHITE)

    // Define buttons positions.
    buttons_positions := [i32(OptionsMenuButton.Count)]MenuButtonWithText{
        {"Draw distance", rl.Rectangle{f32(screen_width)/2-250, f32(screen_height)/2, 0, 0}},
        {"Mouse speed", rl.Rectangle{f32(screen_width)/2-250, f32(screen_height)/2+50, 0, 0}},
        {"Back", rl.Rectangle{f32(screen_width)/2-50, f32(screen_height)-100, 0, 0}},
    }
    // Update buttons size.
    for i in 0..<i32(OptionsMenuButton.Count) {
        buttons_positions[i].rect.width = f32(rl.MeasureText(buttons_positions[i].text, 50))
        buttons_positions[i].rect.x = f32(buttons_positions[i].rect.x) - buttons_positions[i].rect.width/2
        buttons_positions[i].rect.height = 50
    }

    // Check ESC key for main menu.
    if rl.IsKeyPressed(.ESCAPE) {
        return MenuTag.MainMenu
    }

    // Check keyboard input
    if rl.IsKeyPressed(.UP) {
        options_menu_state.selected_button = OptionsMenuButton((i32(options_menu_state.selected_button) - 1) % i32(OptionsMenuButton.Count))
    }
    if rl.IsKeyPressed(.DOWN) {
        options_menu_state.selected_button = OptionsMenuButton((i32(options_menu_state.selected_button) + 1) % i32(OptionsMenuButton.Count))
    }

    for i in 0..<i32(OptionsMenuButton.Count) {
        if rl.CheckCollisionPointRec(mouse_position, buttons_positions[i].rect) {
            options_menu_state.selected_button = OptionsMenuButton(i)
        }
    }

    // Draw buttons.
    for i in 0..<i32(OptionsMenuButton.Count) {
        button_color := rl.WHITE
        if options_menu_state.selected_button == OptionsMenuButton(i) {
            button_color = rl.RED
            rl.DrawRectangleRec(buttons_positions[i].rect, button_color)
        }
        rl.DrawText(buttons_positions[i].text, i32(buttons_positions[i].rect.x), i32(buttons_positions[i].rect.y), 50, rl.WHITE)
    }

    // Draw view distance slider.
    {
        new_view_distance : f32 = options_menu_state.draw_distance
        min_view_distance : f32 = 100.0
        max_view_distance : f32 = 1_000.0
        left_slider_text := rl.TextFormat("%.0f (%.0f)", min_view_distance, new_view_distance)
        right_slider_text := rl.TextFormat("%.0f", max_view_distance)
        rl.GuiSlider(rl.Rectangle{f32(screen_width)/2, f32(screen_height)/2, 300, 50},
            left_slider_text, right_slider_text,
            &new_view_distance, min_view_distance, max_view_distance)
        options_menu_state.draw_distance = new_view_distance
    }

    // Draw mouse speed slider.
    {
        new_mouse_speed : f32 = options_menu_state.mouse_speed
        min_mouse_speed : f32 = 0.01
        max_mouse_speed : f32 = 1.0
        left_slider_text := rl.TextFormat("%.2f (%.2f)", min_mouse_speed, new_mouse_speed)
        right_slider_text := rl.TextFormat("%.2f", max_mouse_speed)
        rl.GuiSlider(rl.Rectangle{f32(screen_width)/2, f32(screen_height)/2+50, 300, 50},
            left_slider_text, right_slider_text,
            &new_mouse_speed, min_mouse_speed, max_mouse_speed)
        options_menu_state.mouse_speed = new_mouse_speed
    }

    // Button activation.
    button_pressed := rl.IsKeyPressed(.ENTER) || rl.IsMouseButtonPressed(.LEFT)
    if button_pressed {
        #partial switch options_menu_state.selected_button {
        case OptionsMenuButton.Back:
            return MenuTag.MainMenu
        }
    }

    return MenuTag.OptionsMenu
}