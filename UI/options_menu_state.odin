package UI

import rl "vendor:raylib"

OptionsMenuButton :: enum i32 {
    DrawDistance,
    MouseSpeed,
    Back,
    Count,
}

OptionsMenuState :: struct {
    using base_menu: BaseMenu,
    selected_button: OptionsMenuButton,
    draw_distance: f32,
    mouse_speed: f32,
}
