using System;
using System.Data;
using System.Runtime.InteropServices;
using Microsoft.DirectX.DirectSound;
using Microsoft.DirectX;
using System.Threading;
using System.Collections;

namespace Asteroids
{
	/// <summary>
	/// Summary description for CommonDraw.
	/// </summary>

	public abstract class CommonOps
	{
      const string SOUND_DIR = "Sounds\\";
      public const int iMaxX = 10000;
      public const int iMaxY = 7500;
      public const double FPS = 60;
      public static Random rndGen = new Random();      
      private static Device devSound;
      private static System.Windows.Forms.Control ctrlSound;
      private static ArrayList alSounds;

      static public void InitSound()
      {
         devSound = new Device();
         ctrlSound = new System.Windows.Forms.Control(null);
         devSound.SetCooperativeLevel(ctrlSound, CooperativeLevel.Priority);
         alSounds = new ArrayList();
      }

      static public void PlayQueuedSounds()
      {
         ArrayList alCopy;

         // Copy the sound list - so we can release the lock
         lock(alSounds)
         {            
            alCopy = new ArrayList(alSounds);
            alSounds.Clear();
         }
         // Play all the sounds
         foreach(string sSoundFile in alCopy)
         {
            SecondaryBuffer bufSound = new SecondaryBuffer(SOUND_DIR + sSoundFile, devSound);
            bufSound.Play(0, BufferPlayFlags.Default);
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
