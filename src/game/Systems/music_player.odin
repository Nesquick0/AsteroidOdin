package Systems

import rl "../../../raylib"

import "../Entities"
import "../Constants"

play_music :: proc(game_state: ^Entities.GameState) {
    // Update music stream.
    rl.UpdateMusicStream(game_state.music)
    rl.SetMusicVolume(game_state.music, game_state.music_volume)

    // Check whether music is playing or it is finished.
    music_length := rl.GetMusicTimeLength(game_state.music)
    music_time_end := game_state.music_start_time + f64(music_length)
    // Music still playing.
    if (music_length > 0.0 && rl.GetTime() <= music_time_end) {
        return
    }

    // Get new random music index.
    random_index := rl.GetRandomValue(0, 100) % len(Constants.MUSIC_LIST)
    if (game_state.music_index == random_index) {
        random_index = (random_index + 1) % len(Constants.MUSIC_LIST)
    }
    game_state.music_index = random_index

    // Unload current music.
    rl.UnloadMusicStream(game_state.music)

    // Load and play new music.
    game_state.music = rl.LoadMusicStream(Constants.MUSIC_LIST[game_state.music_index])
    rl.PlayMusicStream(game_state.music)

    game_state.music_start_time = rl.GetTime()
}