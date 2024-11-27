package UI

import rl "vendor:raylib"

OptionsMenuButton :: enum i32 {
    DrawDistance,
    Back,
    Count,
}

OptionsMenuState :: struct {
    using base_menu: BaseMenu,
    selected_button: OptionsMenuButton,
    draw_distance: f32,
}
