package UI

import rl "../../../raylib"

MenuTag :: enum {
    MainMenu,
    OptionsMenu,
    GameMenu,
    ExitGame,
}

BaseMenu :: struct {
    menu_tag: MenuTag,
    derived: any,
}

new_menu :: proc($T: typeid) -> ^BaseMenu {
    t := new(T)
    t.derived = t^
    return t
}

MenuButtonWithText :: struct {
    text: cstring,
    rect: rl.Rectangle,
}