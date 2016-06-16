# csharp-asteroids

Introduction

This is my own implementation of Asteroids. It is simulated vector based and uses the GDI for graphics. The game itself is fairly object-oriented and should be easy for someone to interpret. There are some issues remaining in the code which I hope some people could help resolve.
Background

I originally wrote an Asteroids game in VB on Windows 3.1 a very long time ago. This is essentially a port of that version. That version had just basic gameplay, but no sounds.
Using the code

Since this game is vector based, it is based on a very large space. All objects are represented in this larger space and then scaled down to the resolution of the display. This seems to work fairly well and allows the same game to be scaled in a window of any size. The playfield owns all the objects and basically loops through to draw each one.

The game features a fancy title screen display and pause. Implementing pause was trivial - I don't know why all games don't incorporate such a feature.

Sounds are played through DirectX. The graphics are drawn using the GDI. DirectX or some other form of display would likely improve things quite a bit.

Each object is in charge of itself. This makes it trivial for animation, since the object essentially handles this for free. There are a few unique situations where things are drawn a little bit differently. The space ship, for example, is responsible for drawing its thrust.

A surprisingly nice effect is generated for the thurst, bullets and explosions. This is done by randomly cycling through a list of colors while drawing. This creates a dazzling effect.

Collision detection is currently trivial. Since the asteroids are all round (see below), it's trivial to just check the distance of any point from the center of the asteroid. When UFO's come (see below) and asteroids get unique shapes, this method won't work - but will be good to see if two objects are close enough to warrant a more complete check.

Object rotation:
Hide   Copy Code

protected void Rotate(double degrees)
{
   double radiansAdjust = degrees * 0.0174532925;
   radians += radiansAdjust/FPS;
   double SinVal = Math.Sin(radians);
   double CosVal = Math.Cos(radians);

   pointsTransformed.Clear();
   Point ptTransformed = new Point(0,0);
   for (int i=0; i<points.Count; i++)
   {
      Point pt = ((Point)points[i]);
      ptTransformed.X = (int)(pt.X * CosVal + pt.Y * SinVal);
      ptTransformed.Y = (int)(pt.X * SinVal - pt.Y * CosVal);
      pointsTransformed.Add(ptTransformed);
   }
}

Drawing an object (in this case, ship):
Hide   Shrink   Copy Code

public new void Draw(ScreenCanvas sc, int iPictX, int iPictY)
{
   switch (state)
   {
      case SHIP_STATE.ALIVE:
         base.Draw(sc, iPictX, iPictY);
         if (bThrustOn)
         {
             //We have points transformed
             //so...  we know where the bottom of the ship is
            ArrayList alPoly = new ArrayList();
            alPoly.Capacity = 3;
            alPoly.Add(pointsTransformed[iPointThrust1]);
            alPoly.Add(pointsTransformed[iPointThrust2]);
            int iThrustSize = rndGen.Next(200) + 100;  random thrust effect
            alPoly.Add(new Point((((Point)pointsTransformed[iPointThrust1]).X +
              ((Point)pointsTransformed[iPointThrust2]).X) / 2 +
              (int)(iThrustSize*Math.Sin(radians)),
              (((Point)pointsTransformed[iPointThrust1]).Y +
              ((Point)pointsTransformed[iPointThrust2]).Y) / 2 +
              (int)(-iThrustSize*Math.Cos(radians))));
             //Draw thrust directly to ScreenCanvas
             //it's not really part of the ship object
            DrawPolyToSC(alPoly, sc, iPictX, iPictY, GetRandomFireColor());
         }
         break;
   }

Points of Interest

Controls:

    Thrust - up arrow
    Rotate right - right arrow
    Rotate left - left arrow
    Hyperspace - down arrow (there is a risk of explosion on re-entry)
    Shoot - space bar
    Pause - P key. 

There are several things that are a bit annoying or incomplete with this game. They are:

    Sometimes the game completely freezes. I think this is due to sound.
    The game seems to work fine up to resolutions above 1024x768. I am sure this is due to my goofy drawing and page-flipping algorithm. It's pretty amazing that this game performs no better than my old VB version in this regard.
    Sometimes the game slows to a crawl while thrusting. Releasing thrust and it's fine.
    Sometimes there is an exception thrown at shutdown of the game.
    No UFOs - yet. I need some help on smart bullet shooting logic.
    Asteroids are all round. They do rotate. I'd like to get bumpy asteroids like the arcade. This should be fairly trivial, but it will make the collision detection a little bit harder.
    Objects jump when going over edge of the screen. This could create the possibility where something that looks like it should have collided will disappear and there won't be a collision unless it occurs where the object flipped to.
    Sounds are in a directory - I couldn't figure out how to embed them into the executable, which would be so much nicer. 

History

    June 15, 2004 - Initial release. 
