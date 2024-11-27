package main

import "core:fmt"
import "base:runtime"
import rl "vendor:raylib"

import "UI"

game_state : GameState

main :: proc() {
    Init()
    Run()
}

Init :: proc() {
    screen_width: i32 = 1600
    screen_height: i32 = i32(screen_width*9.0/16.0)
    game_state = GameState{
        screen_width = screen_width,
        screen_height = screen_height,
        level_tag = LevelTag.MainMenu,
        score = 0,
        menu_state = UI.new_menu(UI.MainMenuState),
        draw_distance = 5_000.0,
    }
}

Run :: proc() {
    rl.InitWindow(game_state.screen_width, game_state.screen_height, "Odin Asteroid")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.DrawFPS(5, 5)

        switch &e in game_state.menu_state.derived {
        case UI.MainMenuState:
            new_menu_Tag : UI.MenuTag = UI.draw_main_menu(&e, game_state.screen_width, game_state.screen_height)
            #partial switch new_menu_Tag {
            case UI.MenuTag.GameMenu:
            case UI.MenuTag.OptionsMenu:
                game_state.menu_state = UI.new_menu(UI.OptionsMenuState)
                option_menu_state := &game_state.menu_state.derived.(UI.OptionsMenuState)
                option_menu_state.draw_distance = game_state.draw_distance
            case UI.MenuTag.ExitGame:
                return
            }
        case UI.OptionsMenuState:
            new_menu_Tag : UI.MenuTag = UI.draw_options_menu(&e, game_state.screen_width, game_state.screen_height)
            game_state.draw_distance = e.draw_distance
            #partial switch new_menu_Tag {
            case UI.MenuTag.MainMenu:
                game_state.menu_state = UI.new_menu(UI.MainMenuState)
            }
        }
    }
}