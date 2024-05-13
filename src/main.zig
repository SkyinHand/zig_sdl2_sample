const c = @cImport({
    @cInclude("SDL.h");
});

pub fn main() !void {
    const WINDOW_W = 800;
    const WINDOW_H = 600;

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.initError;
    }
    defer c.SDL_Quit();

    const window: *c.SDL_Window = c.SDL_CreateWindow("yay square", 800, 150, WINDOW_W, WINDOW_H, c.SDL_WINDOW_SHOWN) orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.windowError;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer: *c.SDL_Renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.rendererError;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const bmp: *c.SDL_Surface = c.SDL_LoadBMP("./hello.bmp") orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.initError;
    };

    const texture = c.SDL_CreateTextureFromSurface(renderer, bmp);
    c.SDL_FreeSurface(bmp);

    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_RenderCopy(renderer, texture, null, null);
    c.SDL_RenderPresent(renderer);

    c.SDL_Delay(5000);
}
