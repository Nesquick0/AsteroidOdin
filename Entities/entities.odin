package Entities

import rl "vendor:raylib"

Entity :: struct {
    transform: rl.Transform,
    velocity: rl.Vector3,
    derived: any,
}

new_entity :: proc($T: typeid) -> Entity {
    t := new(T)
    t.derived = t^
    return t
}

PlayerType :: struct { }

WeaponId :: enum i32 {
    Left,
    Right,
    Count,
}

Player :: struct {
    using entity: Entity,
    player_type: PlayerType,
    reload_countdown: f32,
    weapon_id: WeaponId,
    model: rl.Model,
    camera_pos: rl.Matrix,
}

LaserShot :: struct {
    using entity: Entity,
    model: rl.Model,
}

AsteroidType :: enum i32 {
    Small,
    Medium,
    Large,
}

Asteroid :: struct {
    using entity: Entity,
    model: rl.Model,
    asteroid_type: AsteroidType,
}