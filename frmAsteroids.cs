using System;
using System.Drawing;
using Raylib_cs;

namespace Asteroids
{
/// <summary>
/// Main game class - Raylib-based game loop replacing WinForms.
/// 
/// Controls:
/// - Thrust: Up Arrow or W
/// - Rotate Left: Left Arrow or A
/// - Rotate Right: Right Arrow or D
/// - Hyperspace: Down Arrow
/// - Shoot: Space
/// - Pause: P
/// - Exit: Escape
/// </summary>
public class frmAsteroids
{
      enum Modes { PREP, TITLE, GAME, EXIT };
      private Modes gameStatus;

      private TitleScreen currTitle;
      private Game currGame;
      protected Score score;
      private ScreenCanvas screenCanvas;
      private bool bLeftPressed;
      private bool bRightPressed;
      private bool bUpPressed;

/// <summary>
/// The main entry point for the application.
/// </summary>
[STAThread]
static void Main() 
{
         new frmAsteroids().Run();
}

      public void Run()
      {
         Raylib.InitWindow(800, 600, "Asteroids");
         Raylib.SetTargetFPS((int)CommonOps.FPS);

         CommonOps.InitSound();

         screenCanvas = new ScreenCanvas();
         score = new Score();
         gameStatus = Modes.TITLE;
         currTitle = new TitleScreen();
         currTitle.InitTitleScreen();

         while (!Raylib.WindowShouldClose() && gameStatus != Modes.EXIT)
         {
            HandleInput();
            Update();

            Raylib.BeginDrawing();
            Raylib.ClearBackground(Raylib_cs.Color.Black);
            screenCanvas.Draw();
            Raylib.EndDrawing();

            CommonOps.PlayQueuedSounds();
         }

         CommonOps.CloseSound();
         Raylib.CloseWindow();
      }

      private void HandleInput()
      {
         if (Raylib.IsKeyPressed(KeyboardKey.Escape))
         {
            if (gameStatus == Modes.TITLE)
            {
               gameStatus = Modes.EXIT;
            }
            else if (gameStatus == Modes.GAME)
            {
               score.CancelGame();
               currTitle = new TitleScreen();
               gameStatus = Modes.TITLE;
            }
         }
         else if (gameStatus == Modes.TITLE)
         {
            // Any key press starts a new game
            if (Raylib.GetKeyPressed() != 0)
            {
               score.ResetGame();
               currGame = new Game();
               gameStatus = Modes.GAME;
               bLeftPressed = false;
               bRightPressed = false;
               bUpPressed = false;
            }
         }
         else if (gameStatus == Modes.GAME)
         {
            // Support both arrow keys and WASD for better key rollover
            bLeftPressed = Raylib.IsKeyDown(KeyboardKey.Left) || Raylib.IsKeyDown(KeyboardKey.A);
            bRightPressed = Raylib.IsKeyDown(KeyboardKey.Right) || Raylib.IsKeyDown(KeyboardKey.D);
            bUpPressed = Raylib.IsKeyDown(KeyboardKey.Up) || Raylib.IsKeyDown(KeyboardKey.W);

            if (Raylib.IsKeyPressed(KeyboardKey.Down))
               currGame.Hyperspace();

            if (Raylib.IsKeyPressed(KeyboardKey.Space))
               currGame.Shoot();

            if (Raylib.IsKeyPressed(KeyboardKey.P))
               currGame.Pause();
         }
      }

      private void Update()
      {
         screenCanvas.Clear();
         int width = Raylib.GetScreenWidth();
         int height = Raylib.GetScreenHeight();

         switch (gameStatus)
         {
            case Modes.TITLE:
               score.Draw(screenCanvas, width, height);
               currTitle.DrawScreen(screenCanvas, width, height);
               break;
            case Modes.GAME:
               if (bLeftPressed)
                  currGame.Left();
               if (bRightPressed)
                  currGame.Right();
               currGame.Thrust(bUpPressed);
               currGame.DrawScreen(screenCanvas, width, height, ref score);
               if (currGame.Done())
               {
                  currTitle = new TitleScreen();
                  currTitle.InitTitleScreen();
                  gameStatus = Modes.TITLE;
               }
               break;
         }
      }
}
}
