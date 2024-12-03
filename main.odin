package main

import "core:fmt"
import "base:runtime"
import "core:mem"
import rl "vendor:raylib"

import "UI"
import "Entities"
import "Systems"

DEFAULT_SCREEN_WIDTH: i32 = 1600
DEFAULT_SCREEN_HEIGHT: i32 = i32(DEFAULT_SCREEN_WIDTH*9.0/16.0)

game_state : Entities.GameState

main :: proc() {
    // Tracking allocator.
    when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)

        defer tracking_allocator(&track)
    }

    init()
    run()
    cleanup()
}

init :: proc() {
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

load_shader :: proc(game_state: ^Entities.GameState) {
    game_state.shader_lighting = rl.LoadShader(
        "Data/shaders/lighting.vs",
        "Data/shaders/lighting.fs")
    ambient_loc := rl.GetShaderLocation(game_state.shader_lighting, "ambient")
    ambient_color := rl.Vector4{0.1, 0.1, 0.1, 1.0}
    rl.SetShaderValue(game_state.shader_lighting, ambient_loc, &ambient_color, rl.ShaderUniformDataType.VEC4)
    shine_coef_loc := rl.GetShaderLocation(game_state.shader_lighting, "shineCoef")
    shine_coef : f32 = 0.5
    rl.SetShaderValue(game_state.shader_lighting, shine_coef_loc, &shine_coef, rl.ShaderUniformDataType.FLOAT)
}

run :: proc() {
    rl.SetConfigFlags({ rl.ConfigFlag.WINDOW_RESIZABLE })
    rl.InitWindow(game_state.screen_width, game_state.screen_height, "Odin Asteroid")
    defer rl.CloseWindow()

    //rl.SetTargetFPS(60)

    load_shader(&game_state)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        check_fullscreen(&game_state)
        rl.DrawFPS(5, 5)

        switch &e in game_state.menu_state.derived {
        case UI.MainMenuState:
            new_menu_Tag : UI.MenuTag = UI.draw_main_menu(&e, game_state.screen_width, game_state.screen_height)
            #partial switch new_menu_Tag {
            case UI.MenuTag.GameMenu:
                delete_old_menu(&game_state)
                game_state.menu_state = UI.new_menu(UI.GameHudState)
                Systems.start_game(&game_state)
            case UI.MenuTag.OptionsMenu:
                delete_old_menu(&game_state)
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
                delete_old_menu(&game_state)
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
                delete_old_menu(&game_state)
                game_state.menu_state = UI.new_menu(UI.MainMenuState)
                game_state.level_tag = Entities.LevelTag.MainMenu
            }
        }
    }
}

delete_old_menu :: proc(game_state: ^Entities.GameState) {
    // Delete current menu.
    switch &e in game_state.menu_state.derived {
    case UI.MainMenuState:
        free(&e)
    case UI.OptionsMenuState:
        free(&e)
    case UI.GameHudState:
        free(&e)
    }
}

cleanup :: proc() {
    delete_old_menu(&game_state)
    rl.UnloadShader(game_state.shader_lighting)
}

tracking_allocator :: proc(track: ^mem.Tracking_Allocator) {
    if len(track.allocation_map) > 0 {
        fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
        for _, entry in track.allocation_map {
            fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
        }
    }
    if len(track.bad_free_array) > 0 {
        fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
        for entry in track.bad_free_array {
            fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
        }
    }
    mem.tracking_allocator_destroy(track)
}

check_fullscreen :: proc(game_state: ^Entities.GameState) {
    // Check if window is resized.
    if rl.IsWindowResized() && !rl.IsWindowFullscreen() {
        // Update game state.
        game_state.screen_width = rl.GetScreenWidth()
        game_state.screen_height = rl.GetScreenHeight()
    }

    // Check for alt + enter to toggle fullscreen.
    if (rl.IsKeyPressed(.ENTER) && (rl.IsKeyDown(.LEFT_ALT) || rl.IsKeyDown(.RIGHT_ALT))) || rl.IsKeyPressed(.F11) {
        display := rl.GetCurrentMonitor()
        display_size: [2]i32 = {rl.GetMonitorWidth(display), rl.GetMonitorHeight(display)}
        is_borderless := game_state.screen_width == display_size.x && game_state.screen_height == display_size.y

        if (is_borderless) {
            rl.ToggleBorderlessWindowed()
            // If we are full screen, then go back to the windowed size.
            rl.SetWindowSize(DEFAULT_SCREEN_WIDTH, DEFAULT_SCREEN_HEIGHT)
        }
        else {
            rl.ToggleBorderlessWindowed()
            // If we are not full screen, set the window size to match the monitor we are on.
            rl.SetWindowSize(display_size.x, display_size.y)
        }

        // Update game state.
        game_state.screen_width = rl.GetScreenWidth()
        game_state.screen_height = rl.GetScreenHeight()
    }
}