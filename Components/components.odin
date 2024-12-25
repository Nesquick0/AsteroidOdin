package Components

AsteroidType :: enum i32 {
    Small,
    Medium,
    Large,
}

WeaponId :: enum i32 {
    Left,
    Right,
}
WEAPON_ID_COUNT :: i32(WeaponId.Right) + 1

get_asteroid_size :: proc(asteroid_type: AsteroidType) -> f32 {
    switch asteroid_type {
    case AsteroidType.Small:
        return 0.5
    case AsteroidType.Medium:
        return 1.0
    case AsteroidType.Large:
        return 2.0
    }
    return 0.0
}
