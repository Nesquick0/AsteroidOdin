package main_desktop

import "core:log"
import "core:fmt"
import "core:mem"

import rl "../../raylib"

import "../game"

INIT_WIDTH :: 1280
INIT_HEIGHT :: 720
TITLE :: "Odin Asteroid"

main :: proc() {
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
    defer tracking_allocator(&track)

    rl.SetConfigFlags({ rl.ConfigFlag.WINDOW_RESIZABLE })
    rl.InitWindow(INIT_WIDTH, INIT_HEIGHT, TITLE)
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    context.logger = log.create_console_logger(opt = {
        .Level,
        .Terminal_Color,
        .Short_File_Path,
        .Line,
    })
    defer log.destroy_console_logger(context.logger)

    game.init()
    defer game.fini()

    for !rl.WindowShouldClose() {
        game.frame()
    }
}

tracking_allocator :: proc(track: ^mem.Tracking_Allocator) {
    if len(track.allocation_map) > 0 {
        fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
        for _, entry in track.allocation_map {
            fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
        }
    }
    if len(track.bad_free_array) > 0 {
        fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
        for entry in track.bad_free_array {
            fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
        }
    }
    mem.tracking_allocator_destroy(track)
}