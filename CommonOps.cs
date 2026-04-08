using System;
using System.Collections.Generic;
using System.IO;
using System.Media;

namespace Asteroids
{
	/// <summary>
	/// Summary description for CommonDraw.
	/// </summary>

	public abstract class CommonOps
	{
      static readonly string SOUND_DIR = Path.Combine("Sounds", "");
      public const int iMaxX = 10000;
      public const int iMaxY = 7500;
      public const double FPS = 60;
      public static Random rndGen = new Random();      
      private static List<string> alSounds;

      static public void InitSound()
      {
         alSounds = new List<string>();
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
            try
            {
               SoundPlayer player = new SoundPlayer(SOUND_DIR + sSoundFile);
               player.Play();
            }
            catch
            {
               // Ignore sound playback failures
            }
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
