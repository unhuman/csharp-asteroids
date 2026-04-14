using System;
using Raylib_cs;

namespace Asteroids
{
   /// <summary>
   /// Input manager to handle keyboard and gamepad input with ghosting mitigation.
   /// Provides debouncing and input buffering to work around keyboard limitations.
   /// </summary>
   public static class InputManager
   {
      private static bool prevLeftPressed = false;
      private static bool prevRightPressed = false;
      private static bool prevThrustPressed = false;
      private const float GAMEPAD_DEADZONE = 0.3f;

      public struct InputState
      {
         public bool RotateLeft;
         public bool RotateRight;
         public bool Thrust;
         public bool Hyperspace;
         public bool Shoot;
         public bool Pause;
      }

      /// <summary>
      /// Gets the current input state from keyboard and/or gamepad.
      /// </summary>
      public static InputState GetInput()
      {
         InputState input = new InputState();

         // Keyboard input (Arrow keys or WASD)
         input.RotateLeft = Raylib.IsKeyDown(KeyboardKey.Left) || Raylib.IsKeyDown(KeyboardKey.A);
         input.RotateRight = Raylib.IsKeyDown(KeyboardKey.Right) || Raylib.IsKeyDown(KeyboardKey.D);
         input.Thrust = Raylib.IsKeyDown(KeyboardKey.Up) || Raylib.IsKeyDown(KeyboardKey.W);

        // Gamepad input (if available, overrides or adds to keyboard)
        if (Raylib.IsGamepadAvailable(0))
         {
            AddGamepadInput(ref input);
         }

         // One-shot inputs (always from keyboard if not using gamepad)
         if (!Raylib.IsGamepadAvailable(0))
         {
            input.Hyperspace = Raylib.IsKeyPressed(KeyboardKey.Down);
            input.Shoot = Raylib.IsKeyPressed(KeyboardKey.Space) || Raylib.IsKeyPressed(KeyboardKey.LeftShift);
            input.Pause = Raylib.IsKeyPressed(KeyboardKey.P);
         }

         return input;
      }

      /// <summary>
      /// Adds gamepad input to the current input state.
      /// </summary>
      private static void AddGamepadInput(ref InputState input)
      {
         // D-pad or left stick for rotation
         float leftStickX = Raylib.GetGamepadAxisMovement(0, GamepadAxis.LeftX);
         if (leftStickX < -GAMEPAD_DEADZONE || Raylib.IsGamepadButtonDown(0, GamepadButton.LeftFaceLeft))
            input.RotateLeft = true;
         if (leftStickX > GAMEPAD_DEADZONE || Raylib.IsGamepadButtonDown(0, GamepadButton.LeftFaceRight))
            input.RotateRight = true;

         // Left trigger for thrust
         float leftTrigger = Raylib.GetGamepadAxisMovement(0, GamepadAxis.LeftTrigger);
         if (leftTrigger > 0.5f)
            input.Thrust = true;

         // Action buttons
         input.Hyperspace = Raylib.IsGamepadButtonPressed(0, GamepadButton.MiddleRight);
         input.Shoot = Raylib.IsGamepadButtonPressed(0, GamepadButton.RightFaceDown);
         input.Pause = Raylib.IsGamepadButtonPressed(0, GamepadButton.MiddleLeft);
      }

      /// <summary>
      /// Gets only the newly pressed continuous keys (not held from previous frame).
      /// Useful for detecting transitions to prevent repeated inputs.
      /// </summary>
      public static InputState GetNewContinuousInputs()
      {
         InputState current = GetInput();
         InputState newInputs = new InputState();

         // Only report continuous inputs that weren't pressed last frame
         newInputs.RotateLeft = current.RotateLeft && !prevLeftPressed;
         newInputs.RotateRight = current.RotateRight && !prevRightPressed;
         newInputs.Thrust = current.Thrust && !prevThrustPressed;
         newInputs.Hyperspace = current.Hyperspace;
         newInputs.Shoot = current.Shoot;
         newInputs.Pause = current.Pause;

         // Update previous state
         prevLeftPressed = current.RotateLeft;
         prevRightPressed = current.RotateRight;
         prevThrustPressed = current.Thrust;

         return newInputs;
      }

      /// <summary>
      /// Checks if a gamepad is available.
      /// </summary>
      public static bool IsGamepadActive()
      {
         return Raylib.IsGamepadAvailable(0);
      }

      /// <summary>
      /// Gets gamepad status string for display.
      /// </summary>
      public static string GetGamepadStatus()
      {
         if (Raylib.IsGamepadAvailable(0))
         {
            return "Gamepad Available";
         }
         return "Keyboard Only";
      }
   }
}
