package Entities

import rl "vendor:raylib"
import "../UI"

LevelTag :: enum {
    MainMenu,
    GameLevel,
}

GameState :: struct {
    screen_width: i32,
    screen_height: i32,

    level_tag: LevelTag,
    score: i32,
    menu_state: UI.BaseMenu,

    draw_distance: f32,
    mouse_speed: f32,

    camera: rl.Camera,
    camera_angle: rl.Vector2,

    entities: [dynamic]Entity,
}
