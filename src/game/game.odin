package game

import rl "../../raylib"

import "core:log"
import "UI"
import "Entities"
import "Systems"
import "Constants"

game_state : Entities.GameState

init :: proc() {
    //rl.SetTargetFPS(144)

    log.info("Odin Asteroid")

    game_state = Entities.GameState{
        screen_width = 1280,
        screen_height = 720,
        level_tag = Entities.LevelTag.MainMenu,
        score = 0,
        menu_state = UI.new_menu(UI.MainMenuState),
        draw_distance = 300.0,
        mouse_speed = 0.1,
        music_volume = 1.0,
    }

    load_shader(&game_state)
}

frame :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    switch &e in game_state.menu_state.derived {
    case UI.MainMenuState:
        new_menu_Tag : UI.MenuTag = UI.draw_main_menu(&e, game_state.screen_width, game_state.screen_height)
        #partial switch new_menu_Tag {
        case UI.MenuTag.GameMenu:
            delete_old_menu(&game_state)
            game_state.menu_state = UI.new_menu(UI.GameHudState)
            rl.SetExitKey(rl.KeyboardKey.KEY_NULL) // Disable ESC key
            Systems.start_game(&game_state)
        case UI.MenuTag.OptionsMenu:
            delete_old_menu(&game_state)
            game_state.menu_state = UI.new_menu(UI.OptionsMenuState)
            rl.SetExitKey(rl.KeyboardKey.KEY_NULL) // Disable ESC key
            option_menu_state := &game_state.menu_state.derived.(UI.OptionsMenuState)
            option_menu_state.draw_distance = game_state.draw_distance
            option_menu_state.mouse_speed = game_state.mouse_speed
            option_menu_state.music_volume = game_state.music_volume
        case UI.MenuTag.ExitGame:
            return
        }
    case UI.OptionsMenuState:
        new_menu_Tag : UI.MenuTag = UI.draw_options_menu(&e, game_state.screen_width, game_state.screen_height)
        game_state.draw_distance = e.draw_distance
        game_state.mouse_speed = e.mouse_speed
        game_state.music_volume = e.music_volume
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
            result = false
        }
        // Return to main menu if game is over.
        if !result {
            delete_old_menu(&game_state)
            game_state.menu_state = UI.new_menu(UI.MainMenuState)
            game_state.level_tag = Entities.LevelTag.MainMenu
        }
    }

    // Play music.
    Systems.play_music(&game_state)

    rl.DrawFPS(5, 5)
}

fini :: proc() {
    delete_old_menu(&game_state)
    rl.UnloadShader(game_state.shader_lighting)
}

load_shader :: proc(game_state: ^Entities.GameState) {
    game_state.shader_lighting = rl.LoadShader(
        Constants.LIGHTING_VS_100,
        Constants.LIGHTING_PS_100)
    ambient_loc := rl.GetShaderLocation(game_state.shader_lighting, "ambient")
    ambient_color := rl.Vector4{0.1, 0.1, 0.1, 1.0}
    rl.SetShaderValue(game_state.shader_lighting, ambient_loc, &ambient_color, rl.ShaderUniformDataType.VEC4)
    shine_coef_loc := rl.GetShaderLocation(game_state.shader_lighting, "shineCoef")
    shine_coef : f32 = 16.0
    rl.SetShaderValue(game_state.shader_lighting, shine_coef_loc, &shine_coef, rl.ShaderUniformDataType.FLOAT)
}

delete_old_menu :: proc(game_state: ^Entities.GameState) {
// Delete current menu.
    switch &e in game_state.menu_state.derived {
    case UI.MainMenuState:
        free(&e)
    case UI.OptionsMenuState:
        free(&e)
    case UI.GameHudState:
        Systems.close_game(game_state)
        free(&e)
    }
    rl.SetExitKey(rl.KeyboardKey.ESCAPE) // Enable ESC key
}
