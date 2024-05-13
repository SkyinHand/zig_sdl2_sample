const std = @import("std");
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
});

const sdl = @cImport({
    @cInclude("SDL.h");
});

const sdl_music = @cImport({
    @cInclude("SDL_mixer.h");
});

// play music
pub fn main() !void {
    const WINDOW_W = 800;
    const WINDOW_H = 600;

    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_ERROR, "%s", sdl.SDL_GetError());
        return error.InitSDLError;
    }
    defer sdl.SDL_Quit();

    _ = sdl_music.Mix_Init(sdl_music.MIX_INIT_FLAC);
    defer sdl_music.Mix_Quit();

    const window: *sdl.SDL_Window = sdl.SDL_CreateWindow("yay square", 800, 150, WINDOW_W, WINDOW_H, sdl.SDL_WINDOW_SHOWN) orelse {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_ERROR, "%s", sdl.SDL_GetError());
        return error.WindowError;
    };
    defer sdl.SDL_DestroyWindow(window);

    const renderer: *sdl.SDL_Renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC) orelse {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_ERROR, "%s", sdl.SDL_GetError());
        return error.RendererError;
    };
    defer sdl.SDL_DestroyRenderer(renderer);

    _ = sdl_music.Mix_OpenAudio(sdl_music.MIX_DEFAULT_FREQUENCY, sdl_music.MIX_DEFAULT_FORMAT, sdl_music.MIX_DEFAULT_CHANNELS, 2048);
    defer sdl_music.Mix_CloseAudio();

    const music: *sdl_music.Mix_Music = sdl_music.Mix_LoadMUS("So Far Away.flac") orelse {
        std.debug.print("CANT LOAD MUSIC", .{});
        return error.CantPlayMusic;
    };
    defer sdl_music.Mix_FreeMusic(music);

    _ = sdl_music.Mix_PlayMusic(music, 10);

    var event: sdl.SDL_Event = undefined;

    out: while (true) {
        while (sdl.SDL_PollEvent(&event) == 1) {
            switch (event.type) {
                sdl.SDL_QUIT => {
                    _ = c.puts("Exited!");
                    return;
                },
                sdl.SDL_MOUSEBUTTONDOWN => {
                    _ = c.printf("Button down at (%d, %d)\n", event.button.x, event.button.y);
                },
                sdl.SDL_MOUSEBUTTONUP => {
                    _ = c.printf("Button up at (%d, %d)\n", event.button.x, event.button.y);
                },
                sdl.SDL_KEYDOWN => {
                    _ = c.printf("Key down: %s\n", sdl.SDL_GetKeyName(event.key.keysym.sym));
                },
                sdl.SDL_KEYUP => {
                    _ = c.printf("Key up: %s\n", sdl.SDL_GetKeyName(event.key.keysym.sym));
                    if (event.key.keysym.sym == sdl.SDLK_HOME) {
                        _ = c.puts("Exited by key.");
                        break :out;
                    }
                },
                else => {},
            }
            _ = c.fflush(c.__acrt_iob_func(1));
        }
        sdl.SDL_Delay(5);
    }
}
