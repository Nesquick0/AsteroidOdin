package Systems

import rl "../../../raylib"
import "../Entities"

MAX_LIGHTS :: 4

lightsCount: i32

create_light :: proc(type: Entities.LightType, position, target: [3]f32, color: rl.Color, shader: rl.Shader) ->
    (light: Entities.Light) {
    if lightsCount < MAX_LIGHTS {
        light.enabled = true
        light.type = type
        light.position = position
        light.target = target
        light.color = color

        light.enabledLoc = i32(rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].enabled", lightsCount)))
        light.typeLoc = i32(rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].type", lightsCount)))
        light.positionLoc = i32(rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].position", lightsCount)))
        light.targetLoc = i32(rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].target", lightsCount)))
        light.colorLoc = i32(rl.GetShaderLocation(shader, rl.TextFormat("lights[%i].color", lightsCount)))

        update_light_values(shader, light)

        lightsCount += 1
    }

    return
}

update_light_values :: proc(shader: rl.Shader, light: Entities.Light) {
    light := light

    rl.SetShaderValue(shader, rl.ShaderLocationIndex(light.enabledLoc), &light.enabled, .INT)
    rl.SetShaderValue(shader, rl.ShaderLocationIndex(light.typeLoc), &light.type, .INT)

    rl.SetShaderValue(shader, rl.ShaderLocationIndex(light.positionLoc), &light.position, .VEC3)

    rl.SetShaderValue(shader, rl.ShaderLocationIndex(light.targetLoc), &light.target, .VEC3)

    color := [4]f32{ f32(light.color.r) / 255, f32(light.color.g) / 255, f32(light.color.b) / 255, f32(light.color.a) / 255 }
    rl.SetShaderValue(shader, rl.ShaderLocationIndex(light.colorLoc), &color, .VEC4)
}
