package UI

OptionsMenuButton :: enum i32 {
    DrawDistance,
    MouseSpeed,
    MusicVolume,
    Back,
}

OptionsMenuState :: struct {
    using base_menu: BaseMenu,
    selected_button: OptionsMenuButton,
    draw_distance: f32,
    mouse_speed: f32,
    music_volume: f32,
}
