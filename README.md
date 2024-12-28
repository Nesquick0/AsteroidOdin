# AsteroidOdin

Simple game inspiered by game Asteroids but in 3D programmed with Odin language.

## Building

### Windows
```batch
.\build.bat
```

### WASM

#### Requirements
1. [emsdk](https://emscripten.org/docs/getting_started/downloads.html)

> [!NOTE]  
> In `build_web.bat`, you need to modify the path to where your `emsdk_env.bat` is located

```batch
.\build_web.bat

:: For running
cd build_web
python -m http.server
```

## References
* Odin language: https://odin-lang.org/
* Raylib: https://www.raylib.com/
* Raylib-WASM : https://github.com/Aronicu/Raylib-WASM
* Raylib lights: https://gist.github.com/laytan/b0eed93e0a03f84d5e4aa97794c8395b
* PSX PS1 Low Poly Asteroids: https://www.fab.com/listings/9bb9f649-83ab-4fd7-8c4c-674b1c211513
* Space Ranger SR1: https://www.fab.com/listings/fd6a9c48-1f01-4bf3-9b78-eadca660ed97
* Ovani sound Dark Ambient Music Pack Vol. 1: https://ovanisound.com/products/dark-ambient-music-pack-vol-1?_pos=1&_psq=Dark+Ambient+Music+Pack+Vol.+1&_ss=e&_v=1.0