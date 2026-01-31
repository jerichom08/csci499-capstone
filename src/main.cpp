#include "raylib.h"
#include "resource_dir.h"

int main()
{
    InitWindow(800, 600, "Test");
    SearchAndSetResourceDir("assets");
    SetTargetFPS(60);

    Texture2D cat = LoadTexture("gatito.png");
    if (cat.id == 0)
    {
        TraceLog(LOG_ERROR, "Failed to load gatito.png");
        CloseWindow();
        return 1;
    }

    int x = 100;
    int y = 100;
    int dx = 5, dy = 5;
    int cw = cat.width;
    int ch = cat.height;

    while (!WindowShouldClose())
    {
        x += dx;
        y += dy;

        if (x + cw >= GetScreenWidth() || x <= 0) dx *= -1;
        if (y + ch >= GetScreenHeight() || y <= 0) dy *= -1;

        BeginDrawing();
        ClearBackground(BLACK);
        DrawTexture(cat, x, y, WHITE);
        EndDrawing();
    }

    UnloadTexture(cat);
    CloseWindow();
    return 0;
}
