using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Threading;

namespace Asteroids
{
	/// <summary>
	/// Summary description for frmAsteroids.
	/// </summary>
	public class frmAsteroids : System.Windows.Forms.Form
	{
      enum Modes { PREP, TITLE, GAME, EXIT };
      private Modes gameStatus;
      private System.Windows.Forms.PictureBox frame1;
      private System.Windows.Forms.PictureBox frame2;
      private System.Windows.Forms.PictureBox [] frames;

      private int iShowFrame;
      private bool bLastDrawn;      
      private TitleScreen currTitle;
      private Game currGame;
      protected Score score;
      private ScreenCanvas screenCanvas;
      private bool bLeftPressed;
      private bool bRightPressed;
      private bool bUpPressed;
      private bool bHyperspaceLastPressed;
      private bool bShootingLastPressed;
      private bool bPauseLastPressed;
      private System.Timers.Timer timerFlip;
      private System.Timers.Timer timerSounds;

		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public frmAsteroids()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

         // Initialize DirectSound
         CommonOps.InitSound();         

         // Set the drawing frames to be the window size
         frames = new System.Windows.Forms.PictureBox[2];
         frames[0] = frame1;
         frames[1] = frame2;
         iShowFrame = 0;
         bLastDrawn = false;
         foreach (System.Windows.Forms.PictureBox frame in frames)
         {
            frame.Top = 0;
            frame.Left = 0;
            frame.Width = this.ClientSize.Width;
            frame.Height = this.ClientSize.Height;
         }

         // Set GameStatus to PREP
         gameStatus = Modes.PREP;
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
         base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>

      private void InitializeComponent()
		{
         this.frame1 = new System.Windows.Forms.PictureBox();
         this.frame2 = new System.Windows.Forms.PictureBox();
         this.SuspendLayout();
         // 
         // frame1
         // 
         this.frame1.BackColor = System.Drawing.SystemColors.WindowText;
         this.frame1.Location = new System.Drawing.Point(8, 8);
         this.frame1.Name = "frame1";
         this.frame1.TabIndex = 0;
         this.frame1.TabStop = false;
         this.frame1.Paint += new System.Windows.Forms.PaintEventHandler(this.frame_Paint);
         // 
         // frame2
         // 
         this.frame2.BackColor = System.Drawing.SystemColors.WindowText;
         this.frame2.Location = new System.Drawing.Point(8, 72);
         this.frame2.Name = "frame2";
         this.frame2.TabIndex = 1;
         this.frame2.TabStop = false;
         this.frame2.Paint += new System.Windows.Forms.PaintEventHandler(this.frame_Paint);
         // 
         // frmAsteroids
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(632, 453);
         this.Controls.Add(this.frame2);
         this.Controls.Add(this.frame1);
         this.Name = "frmAsteroids";
         this.Text = "Asteroids";
         this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.frmAsteroids_KeyDown);
         this.Resize += new System.EventHandler(this.frmAsteroids_Resize);
         this.KeyUp += new System.Windows.Forms.KeyEventHandler(this.frmAsteroids_KeyUp);
         this.Closed += new System.EventHandler(this.frmAsteroids_Closed);
         this.Activated += new System.EventHandler(this.frmAsteroids_Activated);
         this.ResumeLayout(false);

      }
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
         Application.Run(new frmAsteroids());
		}

      private void frmAsteroids_Closed(object sender, System.EventArgs e)
      {
         // Ensure game exits when close is hit
         gameStatus = Modes.EXIT;
      }

      private void frmAsteroids_Resize(object sender, System.EventArgs e)
      {
         /* Tries to keep aspect ratio - 
          * doesn't work well
         
         Control cSender = (Control) sender;
         if (Math.Abs(cSender.Width - iLastX) > Math.Abs(cSender.Height - iLastY))
            cSender.Height = (int)(cSender.Width * ((float)CommonDraw.iMaxY / (float)CommonDraw.iMaxX));
         else
            cSender.Width = (int)(cSender.Height * ((float)CommonDraw.iMaxX / (float)CommonDraw.iMaxY));

         iLastX = cSender.Width;
         iLastY = cSender.Height;         
         */

         foreach (System.Windows.Forms.PictureBox frame in frames)
         {
            frame.Width = this.ClientSize.Width;
            frame.Height = this.ClientSize.Height;
         }
      }

      private void frame_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
      {         
         Control control = (Control)sender;
         int iScreenWidth = control.Width;
         int iScreenHeight = control.Height;

         // Only allow the canvas to be drawn once
         // if there is an invalidate, it's ok, 
         // the other canvas will soon be drawn
         if (!bLastDrawn)
         {
            bLastDrawn = true;
            screenCanvas.Draw(e);
         }
      }

      private bool TitleScreen(TitleScreen thisTitle)
      {
         score.Draw(screenCanvas, this.ClientSize.Width,this.ClientSize.Height);
         currTitle.DrawScreen(screenCanvas, this.ClientSize.Width, this.ClientSize.Height);
         
         return (gameStatus == Modes.TITLE);
      }

      private bool PlayGame(Game thisGame)
      {
         if (bLeftPressed)
            currGame.Left();
         if (bRightPressed)
            currGame.Right();
         currGame.Thrust(bUpPressed);
         
         currGame.DrawScreen(screenCanvas, this.ClientSize.Width,this.ClientSize.Height, ref score);
         
         // If the game is over, display the title screen
         if (currGame.Done())
            gameStatus = Modes.TITLE;

         return (gameStatus == Modes.GAME);
      }

      // Specify what you want to happen when the event is raised.
      private void FlipDisplay(object source, System.Timers.ElapsedEventArgs e) 
      {
         // Draw the next screen
         screenCanvas.Clear();         
      
         switch (gameStatus)
         {
            case Modes.TITLE:
               TitleScreen(currTitle);
               break;
            case Modes.GAME:
               if (!PlayGame(currGame))
               {
                  currTitle = new TitleScreen();
                  currTitle.InitTitleScreen();
               }
               break;
         }
      
         // Flip the screen to show the updated image
         bLastDrawn = false;
         frames[iShowFrame].BringToFront();
         frames[iShowFrame].Visible = true;         
         iShowFrame = 1-iShowFrame;
         frames[iShowFrame].Visible = false;

         // Set another timer...
         if (gameStatus != Modes.EXIT)
            SetFlipTimer();
      }

      private void PlaySounds(object source, System.Timers.ElapsedEventArgs e)
      {
         CommonOps.PlayQueuedSounds();
         // Set another timer...
         if (gameStatus != Modes.EXIT)
            SetSoundsTimer();
      }

      private void SetFlipTimer()
      {
         // Screen Flip Timer
         timerFlip = new System.Timers.Timer(1000/CommonOps.FPS);
         timerFlip.Elapsed += new System.Timers.ElapsedEventHandler(FlipDisplay);
         timerFlip.AutoReset = false;
         timerFlip.Enabled = true;
      }

      private void SetSoundsTimer()
      {        
         // Sound Play Timer
         timerSounds = new System.Timers.Timer(1000/CommonOps.FPS);
         timerSounds.Elapsed += new System.Timers.ElapsedEventHandler(PlaySounds);
         timerSounds.AutoReset = false;
         timerSounds.Enabled = true;      
      }

      private void frmAsteroids_Activated(object sender, System.EventArgs e)
      {
         if (gameStatus == Modes.PREP)
         {
            screenCanvas = new ScreenCanvas();
            score = new Score();
            gameStatus = Modes.TITLE;
            currTitle = new TitleScreen();
            currTitle.InitTitleScreen();

            // Timers for flipping display and playing sounds
            SetFlipTimer();
            SetSoundsTimer();

            // Handle the game
            do
            {
               Application.DoEvents();
               Thread.Sleep(0);
            } while (gameStatus != Modes.EXIT);
         }
      }

      private void frmAsteroids_KeyDown(object sender, System.Windows.Forms.KeyEventArgs e)
      {
         // Check escape key
         if (e.KeyData == System.Windows.Forms.Keys.Escape) // Escape
         {
            // Escape during a title screen exits the game
            if (gameStatus == Modes.TITLE)
            {
               gameStatus = Modes.EXIT;
               Application.Exit();
            }

            // Escape in game goes back to Title Screen
            if (gameStatus == Modes.GAME)
            {
               score.CancelGame();
               currTitle = new TitleScreen();
               gameStatus = Modes.TITLE;
            }
         }
         else // Not Escape
         {            
            // If we are in tht Title Screen, Start a game
            if (gameStatus == Modes.TITLE)
            {
               score.ResetGame();
               currGame = new Game();
               gameStatus = Modes.GAME;
               bLeftPressed = false;
               bRightPressed = false;
               bUpPressed = false;
               bHyperspaceLastPressed = false;
               bShootingLastPressed = false;
               bPauseLastPressed = false;
            } 
            else // In Game
            {
               // Keydown handled in game
               
               // Rotate Left
               if (e.KeyData == System.Windows.Forms.Keys.Left)
               {
                  bLeftPressed = true;
               }                

               // Rotate Right
               if (e.KeyData == System.Windows.Forms.Keys.Right)
               {
                  bRightPressed = true;
               }                

               // Thrust
               if (e.KeyData == System.Windows.Forms.Keys.Up)
               {
                  bUpPressed = true;
               }
                
               // Hyperspace (can't be held down)
               if (!bHyperspaceLastPressed && (e.KeyData == System.Windows.Forms.Keys.Down))
               {
                  bHyperspaceLastPressed = true;
                  currGame.Hyperspace();
               }
               
               // Shooting (can't be held down)
               if (!bShootingLastPressed && (e.KeyData == System.Windows.Forms.Keys.Space))
               {
                  bShootingLastPressed = true;
                  currGame.Shoot();
               }

               // Pause can't be held down)
               if (!bPauseLastPressed && (e.KeyData == System.Windows.Forms.Keys.P))
               {
                  bPauseLastPressed = true;
                  currGame.Pause();
               }
            }
         }      
      }

      private void frmAsteroids_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
      {
         // Rotate Left
         if (e.KeyData == System.Windows.Forms.Keys.Left)
         {
            bLeftPressed = false;
         }                

         // Rotate Right
         if (e.KeyData == System.Windows.Forms.Keys.Right)
         {
            bRightPressed = false;
         }                

         // Thrust
         if (e.KeyData == System.Windows.Forms.Keys.Up)
         {            
            bUpPressed = false;
         }      

         // Hyperspace - require key up before key down
         if (e.KeyData == System.Windows.Forms.Keys.Down)
         {
            bHyperspaceLastPressed = false;
         }

         // Shooting - require key up before key down
         if (e.KeyData == System.Windows.Forms.Keys.Space)
         {
            bShootingLastPressed = false;
         }

         // Pause - require key up before key down
         if (e.KeyData == System.Windows.Forms.Keys.P)
         {
            bPauseLastPressed = false;
         }
      }
	}
}
