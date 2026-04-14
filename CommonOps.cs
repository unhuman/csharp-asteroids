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
	  private static Dictionary<string, bool> alSounds = new();
	  private static Dictionary<string, Sound> soundCache = new();

      static public void InitSound()
      {
         Raylib.InitAudioDevice();
         alSounds = new Dictionary<string, bool>();
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
         Dictionary<string, bool> alCopy;

         // Copy the sound list - so we can release the lock
         lock(alSounds)
         {            
            alCopy = new Dictionary<string, bool>(alSounds);
            alSounds.Clear();
         }
         // Play all the sounds - only play if not already playing
         foreach(var kvp in alCopy)
         {
            Sound sound = GetOrLoadSound(kvp.Key);
            bool singlePlay = kvp.Value;
            if (!singlePlay || !Raylib.IsSoundPlaying(sound))
            {
               Raylib.PlaySound(sound);
            }
         }
      }

      static public void PlaySound(string sSoundFile, bool singlePlay = false)
      {
         // add sounds under lock
         lock(alSounds)
         {
            if (!alSounds.ContainsKey(sSoundFile))
               alSounds[sSoundFile] = singlePlay;
         }
      }
	}
}
