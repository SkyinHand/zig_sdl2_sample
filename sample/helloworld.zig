const sdl = @cImport({
    @cInclude("SDL.h");
});
pub fn main() !void {
    const WINDOW_W = 800;
    const WINDOW_H = 600;
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_ERROR, "%s", sdl.SDL_GetError());
        return error.InitSDLError;
    }
    defer sdl.SDL_Quit();

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

    const bmp: *sdl.SDL_Surface = sdl.SDL_LoadBMP("./hello.bmp") orelse {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_ERROR, "%s", sdl.SDL_GetError());
        return error.bmpLoadError;
    };

    const texture = sdl.SDL_CreateTextureFromSurface(renderer, bmp);
    sdl.SDL_FreeSurface(bmp);

    _ = sdl.SDL_RenderClear(renderer);
    _ = sdl.SDL_RenderCopy(renderer, texture, null, null);
    sdl.SDL_RenderPresent(renderer);
}
