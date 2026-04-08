# csharp-asteroids

## Introduction

This is my own implementation of Asteroids. It is simulated vector based and uses [Raylib](https://www.raylib.com/) (via [Raylib-cs](https://github.com/ChristianFischer/raylib-cs)) for graphics and audio. The game itself is fairly object-oriented and should be easy for someone to interpret.

## Background

I originally wrote an Asteroids game in VB on Windows 3.1 a very long time ago. This is essentially a port of that version. That version had just basic gameplay, but no sounds.

## Building and Running

Requires .NET 10 SDK.

```bash
dotnet build
dotnet run
```

The game runs cross-platform on Windows, macOS (arm64/x64), and Linux (x64).

## Using the Code

Since this game is vector based, it is based on a very large space. All objects are represented in this larger space and then scaled down to the resolution of the display. This seems to work fairly well and allows the same game to be scaled in a window of any size. The playfield owns all the objects and basically loops through to draw each one.

The game features a fancy title screen display and pause. Implementing pause was trivial - I don't know why all games don't incorporate such a feature.

Graphics are rendered using Raylib's line-drawing primitives. Audio is played through Raylib's built-in audio system with cached sound objects for efficiency.

Each object is in charge of itself. This makes it trivial for animation, since the object essentially handles this for free. There are a few unique situations where things are drawn a little bit differently. The space ship, for example, is responsible for drawing its thrust.

A surprisingly nice effect is generated for the thrust, bullets and explosions. This is done by randomly cycling through a list of colors while drawing. This creates a dazzling effect.

Collision detection is currently trivial. Since the asteroids are all round (see below), it's trivial to just check the distance of any point from the center of the asteroid. When UFO's come (see below) and asteroids get unique shapes, this method won't work - but will be good to see if two objects are close enough to warrant a more complete check.

## Controls

- Thrust - up arrow
- Rotate right - right arrow
- Rotate left - left arrow
- Hyperspace - down arrow (there is a risk of explosion on re-entry)
- Shoot - space bar
- Pause - P key
- Quit - Escape (from title screen) or close window

## Known Issues

- No UFOs - yet. I need some help on smart bullet shooting logic.
- Asteroids are all round. They do rotate. I'd like to get bumpy asteroids like the arcade. This should be fairly trivial, but it will make the collision detection a little bit harder.
- Objects jump when going over edge of the screen. This could create the possibility where something that looks like it should have collided will disappear and there won't be a collision unless it occurs where the object flipped to.

## History

- June 15, 2004 - Initial release (WinForms + GDI + DirectX DirectSound, .NET Framework 1.1).
- 2026 - Upgraded to .NET 10 with Raylib-cs. Replaced WinForms/GDI rendering with Raylib, replaced DirectX DirectSound with Raylib audio. Now cross-platform.
