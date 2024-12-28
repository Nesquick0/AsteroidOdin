package Entities

import rl "../../../raylib"

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


/*
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
*/

// Entities as composition.
Entity :: struct {
    transform: rl.Transform,
    velocity: rl.Vector3,
    ang_velocity: rl.Vector3,

    shape: union {SimpleLine, Model},
    logic: union {Player, LaserShot, Asteroid},
}

// Models
SimpleLine :: struct {}
Model :: struct {
    model: rl.Model,
    size: f32,
}

// Logic
Player :: struct {
    reload_countdown: f32,
    weapon_id: Components.WeaponId,
    camera_pos: rl.Matrix,
}
LaserShot :: struct {
    time_to_live: f32,
}
Asteroid :: struct {
    asteroid_type: Components.AsteroidType,
}