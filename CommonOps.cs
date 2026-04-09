using System;
using System.Collections.Generic;
using System.IO;
using Raylib_cs;

namespace Asteroids
{
	/// <summary>
	/// Summary description for CommonDraw.
	/// </summary>

	public abstract class CommonOps
	{
	  public const int iMaxX = 10000;
	  public const int iMaxY = 7500;
	  public const double FPS = 60;
	  public static Random rndGen = new Random();
      private static List<string> alSounds;
      private static Dictionary<string, Sound> soundCache = new();

      static public void InitSound()
      {
         Raylib.InitAudioDevice();
         alSounds = new List<string>();
      }

      static public void CloseSound()
      {
         foreach (var sound in soundCache.Values)
            Raylib.UnloadSound(sound);
         soundCache.Clear();
         Raylib.CloseAudioDevice();
      }

      private static Sound GetOrLoadSound(string fileName)
      {
         if (!soundCache.TryGetValue(fileName, out Sound sound))
         {
            string soundPath = Path.Combine("Sounds", fileName);
            sound = Raylib.LoadSound(soundPath);
            soundCache[fileName] = sound;
         }
         return sound;
      }

      static public void PlayQueuedSounds()
      {
         List<string> alCopy;

         // Copy the sound list - so we can release the lock
         lock(alSounds)
         {            
            alCopy = new List<string>(alSounds);
            alSounds.Clear();
         }
         // Play all the sounds
         foreach(string sSoundFile in alCopy)
         {
            Sound sound = GetOrLoadSound(sSoundFile);
            Raylib.PlaySound(sound);
         }
      }

      static public void PlaySound(string sSoundFile)
      {
         // add sounds under lock
         lock(alSounds)
         {
            if (!alSounds.Contains(sSoundFile))
               alSounds.Add(sSoundFile);
         }
      }
	}
}
