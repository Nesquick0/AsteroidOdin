package UI

import rl "vendor:raylib"

MenuButton :: enum i32 {
    StartGame,
    Options,
    Exit,
    Count,
}

MainMenuState :: struct {
    using base_menu: BaseMenu,
    selected_button: MenuButton,
}
