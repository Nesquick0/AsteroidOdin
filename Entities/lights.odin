package Entities

import rl "vendor:raylib"

Light :: struct {
    type: LightType,
    enabled: b32,
    position: [3]f32,
    target: [3]f32,
    color: rl.Color,
    attenuation: f32,
    enabledLoc: i32,
    typeLoc: i32,
    positionLoc: i32,
    targetLoc: i32,
    colorLoc: i32,
    attenuationLoc: i32,
}

LightType :: enum i32 {
    Directional,
    Point,
}