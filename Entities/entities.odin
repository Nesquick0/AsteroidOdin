package Entities

import rl "vendor:raylib"

import "../Components"

/*
// Entities with derived type as any.
Entity :: struct {
    transform: rl.Transform,
    velocity: rl.Vector3,
    ang_velocity: rl.Vector3,
    derived: any,
}

new_entity :: proc($T: typeid) -> ^Entity {
    t := new(T)
    t.derived = t^
    return t
}

Player :: struct {
    using entity: Entity,
    player_type: Components.PlayerType,
    reload_countdown: f32,
    weapon_id: Components.WeaponId,
    model: rl.Model,
    camera_pos: rl.Matrix,
    size: f32,
}

LaserShot :: struct {
    using entity: Entity,
    time_to_live: f32,
    model: rl.Model,
}

Asteroid :: struct {
    using entity: Entity,
    model: rl.Model,
    asteroid_type: Components.AsteroidType,
    size: f32,
}
*/


// Entities as union.
Entity :: struct {
    transform: rl.Transform,
    velocity: rl.Vector3,
    ang_velocity: rl.Vector3,
    derived: union {
        Player,
        LaserShot,
        Asteroid,
    },
}

new_entity :: proc($T: typeid) -> ^Entity {
    t := new(Entity)
    t.derived = T{entity = t}
    return t
}

Player :: struct {
    using entity: ^Entity,
    player_type: Components.PlayerType,
    reload_countdown: f32,
    weapon_id: Components.WeaponId,
    model: rl.Model,
    camera_pos: rl.Matrix,
    size: f32,
}

LaserShot :: struct {
    using entity: ^Entity,
    time_to_live: f32,
    model: rl.Model,
}

Asteroid :: struct {
    using entity: ^Entity,
    model: rl.Model,
    asteroid_type: Components.AsteroidType,
    size: f32,
}
