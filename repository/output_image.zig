pub fn main() !void {
    const bmp: *c.SDL_Surface = c.SDL_LoadBMP("./hello.bmp") orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.bmpLoadError;
    };

    const texture = c.SDL_CreateTextureFromSurface(renderer, bmp);
    c.SDL_FreeSurface(bmp);

    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_RenderCopy(renderer, texture, null, null);
    c.SDL_RenderPresent(renderer);
}
