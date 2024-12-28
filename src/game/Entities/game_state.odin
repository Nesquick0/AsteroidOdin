package Entities

import rl "../../../raylib"
import "../UI"
import "../Components"

LevelTag :: enum {
    MainMenu,
    GameLevel,
}

GameState :: struct {
    screen_width: i32,
    screen_height: i32,
    start_time: f64,

    music: rl.Music,
    music_index: i32,
    music_start_time: f64,

    level_tag: LevelTag,
    score: i32,
    menu_state: ^UI.BaseMenu,
    game_over: bool,

    draw_distance: f32,
    mouse_speed: f32,
    music_volume: f32,

    camera: rl.Camera,
    camera_angle: rl.Vector2,
    frustum: Components.Frustum,
    update_frustum: bool,

    shader_lighting: rl.Shader,
    sun_light: Light,

    max_asteroids: i32,

    entities: [dynamic]^Entity,
}
