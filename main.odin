package main

import "core:fmt"
import "base:runtime"
import rl "vendor:raylib"

import "UI"
import "Entities"
import "Systems"

DEFAULT_SCREEN_WIDTH: i32 = 1600
DEFAULT_SCREEN_HEIGHT: i32 = i32(DEFAULT_SCREEN_WIDTH*9.0/16.0)

game_state : Entities.GameState

main :: proc() {
    Init()
    Run()
}

Init :: proc() {
    screen_width: i32 = DEFAULT_SCREEN_WIDTH
    screen_height: i32 = DEFAULT_SCREEN_HEIGHT
    game_state = Entities.GameState{
        screen_width = screen_width,
        screen_height = screen_height,
        level_tag = Entities.LevelTag.MainMenu,
        score = 0,
        menu_state = UI.new_menu(UI.MainMenuState),
        draw_distance = 500.0,
        mouse_speed = 0.1,
    }
}

Run :: proc() {
    rl.InitWindow(game_state.screen_width, game_state.screen_height, "Odin Asteroid")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.DrawFPS(5, 5)

        switch &e in game_state.menu_state.derived {
        case UI.MainMenuState:
            new_menu_Tag : UI.MenuTag = UI.draw_main_menu(&e, game_state.screen_width, game_state.screen_height)
            #partial switch new_menu_Tag {
            case UI.MenuTag.GameMenu:
                game_state.menu_state = UI.new_menu(UI.GameHudState)
                Systems.start_game(&game_state)
            case UI.MenuTag.OptionsMenu:
                game_state.menu_state = UI.new_menu(UI.OptionsMenuState)
                option_menu_state := &game_state.menu_state.derived.(UI.OptionsMenuState)
                option_menu_state.draw_distance = game_state.draw_distance
                option_menu_state.mouse_speed = game_state.mouse_speed
            case UI.MenuTag.ExitGame:
                return
            }
        case UI.OptionsMenuState:
            new_menu_Tag : UI.MenuTag = UI.draw_options_menu(&e, game_state.screen_width, game_state.screen_height)
            game_state.draw_distance = e.draw_distance
            game_state.mouse_speed = e.mouse_speed
            #partial switch new_menu_Tag {
            case UI.MenuTag.MainMenu:
                game_state.menu_state = UI.new_menu(UI.MainMenuState)
            }
        case UI.GameHudState:
            result := Systems.run_game(&game_state)
            new_menu_Tag : UI.MenuTag = UI.draw_game_hud(&e, game_state.screen_width, game_state.screen_height)
            #partial switch new_menu_Tag {
            case UI.MenuTag.MainMenu:
                result := false
            }
            // Return to main menu if game is over.
            if !result {
                Systems.close_game(&game_state)
                game_state.menu_state = UI.new_menu(UI.MainMenuState)
                game_state.level_tag = Entities.LevelTag.MainMenu
            }
        }
    }
}