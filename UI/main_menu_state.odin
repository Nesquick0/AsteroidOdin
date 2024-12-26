package UI

MenuButton :: enum i32 {
    StartGame,
    Options,
    Exit,
}

MainMenuState :: struct {
    using base_menu: BaseMenu,
    selected_button: MenuButton,
}
