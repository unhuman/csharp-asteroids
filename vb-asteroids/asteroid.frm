VERSION 2.00
Begin Form frmAsteroids 
   Caption         =   "Cheesy Asteroids Clone For Education Purposes"
   ClientHeight    =   5050
   ClientLeft      =   5200
   ClientTop       =   1970
   ClientWidth     =   6520
   Height          =   5450
   Left            =   5120
   LinkTopic       =   "Form1"
   ScaleHeight     =   5050
   ScaleWidth      =   6520
   Top             =   1650
   Width           =   6680
   Begin Timer timerScreenSwap 
      Left            =   120
      Top             =   120
   End
   Begin PictureBox Asteroids 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      ForeColor       =   &H00FFFFFF&
      Height          =   970
      Index           =   0
      Left            =   120
      ScaleHeight     =   950
      ScaleWidth      =   1190
      TabIndex        =   0
      Top             =   1320
      Width           =   1210
   End
   Begin PictureBox Asteroids 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      ForeColor       =   &H00FFFFFF&
      Height          =   970
      Index           =   1
      Left            =   1440
      ScaleHeight     =   950
      ScaleWidth      =   1190
      TabIndex        =   1
      Top             =   1320
      Width           =   1210
   End
End
Option Explicit

Dim PictWidth As Integer
Dim PictHeight As Integer

Const MaxX = 10000
Const MaxY = 7500
Const SAFEDIST = 2000
Const PI = 3.141593

Const MaxAsteroids = 100

Dim GameStatus As Integer
   Const Prep = 0
   Const INTITLE = 1
   Const INGAME = 2

Dim ShipUFOArray(9) As Coord
Dim AsteroidArray(9) As Coord
Dim AsteroidTemplate(9) As Coord

Dim NumShips As Integer
Dim LastScoreGiven As Integer
Const AWARDSHIP = 10000
Dim Ship As ShipType
Dim Bullets(5) As BulletType 'Bullet 5 is the UFO's
Dim AsteroidField(MaxAsteroids) As AsteroidType
Dim Explosions(MaxAsteroids) As ExplosionType
Dim ExplosionPieces(9) As ExplosionPieceType
Dim UFO As UFOType
Dim AllowShot As Integer
Dim Level As Integer

Dim Region As Integer
Dim hBrushWhite As Integer
Dim hBrushRed As Integer
Dim hPenWhite As Integer
Dim hPenRed As Integer
Dim Dummy
Dim AllowFire As Integer
Dim AllowHyperspace As Integer


Dim TimerPop As Integer
Dim Score As Long
Dim HiScore As Long
Dim TitleDone As Integer

Sub Asteroids_KeyDown (Index As Integer, KeyCode As Integer, Shift As Integer)
   If GameStatus = INGAME Then
      Select Case KeyCode
         Case 27 'Escape (back to title screen)
            GameStatus = INTITLE
      End Select
   ElseIf GameStatus = INTITLE Then
      If KeyCode = 27 Then End 'Escape
      TitleDone = True
   End If
   KeyCode = 0
End Sub

Sub Asteroids_KeyUp (Index As Integer, KeyCode As Integer, Shift As Integer)
   Ship.ThrustOn = False
End Sub

Sub CalcAsteroids ()
   Dim SinVal  As Double
   Dim CosVal As Double
   Dim Radians As Double
   
   Dim i As Integer
   For i = 1 To 9
      Radians = i * (360 / 9) * PI / 180
      AsteroidTemplate(i).X = Sin(Radians) * 100 '+ Rnd * 50 - 25
      AsteroidTemplate(i).Y = Cos(Radians) * 100 '+ Rnd * 50 - 25
      ExplosionPieces(i).XVel = 100 * Rnd - 50
      ExplosionPieces(i).YVel = 100 * Rnd - 50
   Next 'i
End Sub

Function CheckCenterSafe () As Integer
   Dim i As Integer

   CheckCenterSafe = True
   'Thrust causes mandatory playing
   If Ship.ThrustOn = True Then
      Exit Function
   End If
   For i = 1 To MaxAsteroids
      If AsteroidField(i).Size > 0 Then
         If Sqr((AsteroidField(i).X - MaxX / 2) ^ 2 + (AsteroidField(i).Y - MaxY / 2) ^ 2) < SAFEDIST Then
            CheckCenterSafe = False
            Exit Function
         End If
      End If
   Next 'i
   For i = 1 To 5
      If Bullets(i).HowLong > 0 Then
         If Sqr((Bullets(i).X - MaxX / 2) ^ 2 + (Bullets(i).Y - MaxY / 2) ^ 2) < SAFEDIST Then
            CheckCenterSafe = False
            Exit Function
         End If
      End If
   Next 'i
   If UFO.Size > 0 Then
      If Sqr((UFO.X - MaxX / 2) ^ 2 + (UFO.Y - MaxY / 2) ^ 2) < SAFEDIST Then
         CheckCenterSafe = False
         Exit Function
      End If
   End If
End Function

Sub CheckCollisions (NumAsteroids As Integer)
   Dim i As Integer
   Dim j As Integer
   Dim k As Integer
   
   'Check Bullets hitting UFOs, Ship, or Asteroids
   For i = 1 To 5
      If Bullets(i).HowLong > 0 Then
         For j = 1 To MaxAsteroids
            If AsteroidField(j).Size > 0 Then
               If Sqr((Bullets(i).X - AsteroidField(j).X) ^ 2 + (Bullets(i).Y - AsteroidField(j).Y) ^ 2) < AsteroidField(j).Size * 200 Then
                  Bullets(i).HowLong = 0
                  DestroyAsteroid j, NumAsteroids, i < 5
                  For k = 1 To MaxAsteroids
                     If Explosions(k).HowLong = 0 Then
                        Explosions(k).HowLong = EXPLOSIONLIFE
                        Explosions(k).X = Bullets(i).X
                        Explosions(k).Y = Bullets(i).Y
                        Exit For
                     End If
                  Next 'k
                  Exit For
               End If
            End If
         Next 'j
         If i < 5 Then 'CheckUFO collision with Ship's Bullets
             If UFO.Size <> 0 And PtInRegion(UFO.RegionHandle, Bullets(i).X / MaxX * PictWidth, Bullets(i).Y / MaxY * PictHeight) <> 0 Then
               DestroyUFO (True)
               Bullets(i).HowLong = 0
            End If
         Else 'CheckShip collision with UFO's Bullet
            If Ship.X <> -1 And PtInRegion(Ship.RegionHandle, Bullets(i).X / MaxX * PictWidth, Bullets(i).Y / MaxY * PictHeight) <> 0 Then
               DestroyShip
               Bullets(i).HowLong = 0
            End If
         End If
      End If
   Next 'i
   
   If Ship.X <> -1 Then
      For i = 1 To 5
         'Check Ship Hitting Asteroids
         For j = 1 To MaxAsteroids
            If AsteroidField(j).Size > 0 Then
               If Sqr((Ship.ShipArray(i).X - AsteroidField(j).X) ^ 2 + (Ship.ShipArray(i).Y - AsteroidField(j).Y) ^ 2) < AsteroidField(j).Size * 200 Then
                  DestroyAsteroid j, NumAsteroids, True
                  DestroyShip
                  Exit For
               End If
            End If
            'Check Ship Hitting UFO
            If UFO.Size <> 0 And Ship.X <> -1 And PtInRegion(UFO.RegionHandle, Ship.ShipArray(i).X / MaxX * PictWidth, Ship.ShipArray(i).Y / MaxY * PictHeight) <> 0 Then
               DestroyUFO (True)
               DestroyShip
            End If
         Next 'j
      Next 'i
   End If

      'Check UFO Hitting Asteroids
   If UFO.Size > 0 Then
      For i = 1 To 7
         For j = 1 To MaxAsteroids
            If AsteroidField(j).Size > 0 Then
               If Sqr((UFO.UFOArray(i).X - AsteroidField(j).X) ^ 2 + (UFO.UFOArray(i).Y - AsteroidField(j).Y) ^ 2) < AsteroidField(j).Size * 200 Then
                  DestroyAsteroid j, NumAsteroids, False
                  DestroyUFO (False)
                  Exit For
               End If
            End If
         Next 'j
      Next 'i
   End If
End Sub

Sub CreateAsteroidField (ByVal Level As Integer, AsteroidCount As Integer)
   Dim i As Integer

   AsteroidCount = Level + 3
   For i = 1 To MaxAsteroids
      If i <= AsteroidCount Then
         AsteroidField(i).X = Int(Rnd) * MaxX
         AsteroidField(i).Y = Rnd * MaxY
         AsteroidField(i).XVel = Rnd * 180 - 90
         AsteroidField(i).YVel = Rnd * 180 - 90
         If GameStatus = INTITLE Then
            AsteroidField(i).Size = Rnd * 3 + 1
            If AsteroidField(i).Size = 3 Then
               AsteroidField(i).Size = 4
            End If
         Else
            AsteroidField(i).Size = 4
         End If
      Else
         AsteroidField(i).Size = 0
      End If
   Next 'i
End Sub

Sub CreateBullet ()
   Dim i As Integer
   Dim SinVal As Double
   Dim CosVal As Double
   
   If Ship.X = -1 Then
      Exit Sub
   End If
   SinVal = Sin(Ship.Radians)
   CosVal = Cos(Ship.Radians)
   For i = 1 To 4
      If Bullets(i).HowLong = 0 Then
         Bullets(i).HowLong = BULLETLIFE
         Bullets(i).X = Ship.ShipArray(1).X
         Bullets(i).Y = Ship.ShipArray(1).Y
         Bullets(i).XVel = Ship.XVel + 150 * SinVal
         Bullets(i).YVel = Ship.YVel + 150 * CosVal
         Exit Sub
      End If
   Next 'i
End Sub

Sub CreateUFOBullet ()
   Dim Radians As Double
   
   Radians = Rnd * MaxRadians
   Bullets(5).HowLong = BULLETLIFE
   Bullets(5).X = UFO.X
   Bullets(5).Y = UFO.Y
   Bullets(5).XVel = 205
   Bullets(5).YVel = 0
End Sub

Sub DestroyAsteroid (AsterNum As Integer, NumAsteroids As Integer, AwardPoints As Integer)
   Dim i As Integer

   If AsteroidField(AsterNum).Size = 4 Then
      AsteroidField(AsterNum).Size = 2
      If AwardPoints = True Then
         Score = Score + 50
      End If
   Else
      AsteroidField(AsterNum).Size = AsteroidField(AsterNum).Size - 1
      If AwardPoints = True Then
         Score = Score + 250 - AsteroidField(AsterNum).Size * 150
      End If
   End If
   If AsteroidField(AsterNum).Size > 0 Then
      NumAsteroids = NumAsteroids + 1
      AsteroidField(AsterNum).XVel = Rnd * 180 - 90
      AsteroidField(AsterNum).YVel = Rnd * 180 - 90
      For i = 1 To MaxAsteroids
         If AsteroidField(i).Size = 0 Then
            AsteroidField(i) = AsteroidField(AsterNum)
            AsteroidField(i).XVel = Rnd * 180 - 90
            AsteroidField(i).YVel = Rnd * 180 - 90
            GoTo DoneDestroyAsteroid
         End If
      Next 'i
   Else
      NumAsteroids = NumAsteroids - 1
   End If
DoneDestroyAsteroid:
   Exit Sub
End Sub

Sub DestroyShip ()
   Dim k As Integer
   Dim ExpCount As Integer
   ExpCount = 1
   For k = 1 To MaxAsteroids
      If Explosions(k).HowLong = 0 Then
         Explosions(k).HowLong = EXPLOSIONLIFE
         Select Case ExpCount
            Case 1 To 5
               Explosions(k).X = Ship.ShipArray(ExpCount).X
               Explosions(k).Y = Ship.ShipArray(ExpCount).Y
            Case Else
               Explosions(k).X = Ship.X
               Explosions(k).Y = Ship.Y
               Exit For
            End Select
         ExpCount = ExpCount + 1
      End If
   Next 'k
   Ship.XVel = 0
   Ship.YVel = 0
   Ship.X = -1
End Sub

Sub DestroyUFO (AwardPoints As Integer)
   Dim k As Integer
   Dim ExpCount As Integer
   
   ExpCount = 1
   For k = 1 To MaxAsteroids
      If Explosions(k).HowLong = 0 Then
         Explosions(k).HowLong = EXPLOSIONLIFE
         Select Case k
            Case 1 To 7
               Explosions(k).X = UFO.UFOArray(ExpCount).X
               Explosions(k).Y = UFO.UFOArray(ExpCount).Y
            Case Else
               Explosions(k).X = UFO.X
               Explosions(k).Y = UFO.Y
               Exit For
         End Select
         ExpCount = ExpCount + 1
      End If
   Next 'k
      If AwardPoints = True Then
         Score = Score + 250 * (3 - UFO.Size)
   End If
   UFO.Size = 0
End Sub

Sub DrawAsteroid (ByVal Window As Integer, ByVal WhichAsteroid As Integer)
   Dim i As Integer
   If AsteroidField(WhichAsteroid).X < 0 Then
      AsteroidField(WhichAsteroid).X = MaxX
   End If
   If AsteroidField(WhichAsteroid).X > MaxX Then
      AsteroidField(WhichAsteroid).X = 0
   End If
   If AsteroidField(WhichAsteroid).Y < 0 Then
      AsteroidField(WhichAsteroid).Y = MaxY
   End If
   If AsteroidField(WhichAsteroid).Y > MaxY Then
      AsteroidField(WhichAsteroid).Y = 0
   End If

   For i = 1 To 9
      AsteroidArray(i).X = (AsteroidField(WhichAsteroid).X + (AsteroidTemplate(i).X * AsteroidField(WhichAsteroid).Size * 2)) / MaxX * PictWidth
      AsteroidArray(i).Y = (AsteroidField(WhichAsteroid).Y + (AsteroidTemplate(i).Y * AsteroidField(WhichAsteroid).Size * 2)) / MaxY * PictHeight
   Next 'i
   Dummy = Polygon(Asteroids(Window).hDC, AsteroidArray(1), 9)
End Sub

Sub DrawBullets (ByVal Window As Integer)
   Dim i As Integer
   Dim X As Integer
   Dim Y As Integer
   Dim Size As Integer
   
   For i = 1 To 5
       If Bullets(i).HowLong > 0 Then
         Bullets(i).X = Bullets(i).X + Bullets(i).XVel
         Bullets(i).Y = Bullets(i).Y + Bullets(i).YVel
         If Bullets(i).X < 0 Then
            Bullets(i).X = MaxX
         End If
         If Bullets(i).X > MaxX Then
            Bullets(i).X = 0
         End If
         If Bullets(i).Y < 0 Then
            Bullets(i).Y = MaxY
         End If
         If Bullets(i).Y > MaxY Then
            Bullets(i).Y = 0
         End If
         X = (Bullets(i).X) / MaxX * PictWidth
         Y = (Bullets(i).Y) / MaxY * PictHeight
         Size = Bullets(i).HowLong Mod 3 + 1
         ShipUFOArray(1).X = X
         ShipUFOArray(1).Y = Y - Size
         ShipUFOArray(2).X = X - Size
         ShipUFOArray(2).Y = Y
         ShipUFOArray(3).X = X
         ShipUFOArray(3).Y = Y + Size
         ShipUFOArray(4).X = X + Size
         ShipUFOArray(4).Y = Y
         Dummy = Polygon(Asteroids(Window).hDC, ShipUFOArray(1), 4)
      End If
   Next 'i
End Sub

Sub DrawExplosions (ByVal Window As Integer)
   Dim i As Integer
   Dim j As Integer
   Dim Dummy As Integer
   
   For i = 1 To MaxAsteroids
      If Explosions(i).HowLong > 0 Then
          Explosions(i).HowLong = Explosions(i).HowLong - 1
          For j = 1 To 9
            ShipUFOArray(1).X = (Explosions(i).X + (EXPLOSIONLIFE - Explosions(i).HowLong + 1) * ExplosionPieces(j).XVel) / MaxX * PictWidth
            ShipUFOArray(1).Y = (Explosions(i).Y + (EXPLOSIONLIFE - Explosions(i).HowLong + 1) * ExplosionPieces(j).YVel) / MaxY * PictHeight
            ShipUFOArray(2).X = ShipUFOArray(1).X + 1
            ShipUFOArray(2).Y = ShipUFOArray(1).Y
            Dummy = Polygon(Asteroids(Window).hDC, ShipUFOArray(1), 2)
         Next 'j
      End If
   Next 'i
End Sub

Sub DrawNumChar (ByVal Window As Integer, Char As String, LetterLeft As Integer, LetterTop As Integer, LetterWidth As Integer, LetterHeight As Integer)
   Dim NewLeft As Integer
   Dim NewTop As Integer
   Dim HalfRight As Integer
   Dim HalfDown As Integer
   Dim RightSide As Integer
   Dim BottomSide As Integer

   NewLeft = LetterLeft + LetterWidth * .2
   NewTop = LetterTop + LetterHeight * .1
   HalfRight = (NewLeft + LetterLeft + LetterWidth) / 2
   HalfDown = (NewTop + LetterTop + LetterHeight) / 2
   RightSide = LetterLeft + LetterWidth
   BottomSide = LetterTop + LetterHeight
   Select Case Char
      Case "0", "O"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
      Case "1", "I"
         Dummy = MoveTo(Asteroids(Window).hDC, HalfRight, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, BottomSide)
      Case "2"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "3"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
      Case "4"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "5", "S"
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
      Case "6"
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
      Case "7"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "8", "B"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
      Case "9"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
      Case "x"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
      Case "^" ' Ship
         Dummy = MoveTo(Asteroids(Window).hDC, HalfRight, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, NewTop)
      Case "A"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
      'Case "B" handled by "8"
      Case "C"
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "D"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
      Case "E"
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
      Case "F"
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
      Case "G"
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, HalfDown)
      Case "H"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
      'Case "I" handled by "1"
      Case "J"
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
      Case "K"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "L"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "M"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "N"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
      'Case "O" handled by "0"
      Case "P"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
      Case "Q"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = MoveTo(Asteroids(Window).hDC, HalfRight, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      Case "R"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
      'Case "S" handled by "5"
      Case "T"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = MoveTo(Asteroids(Window).hDC, HalfRight, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, BottomSide)
      Case "U"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
      Case "V"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
      Case "W"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, HalfDown)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
      Case "X"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
      Case "Y"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, HalfRight, HalfDown)
         Dummy = MoveTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
      Case "Z"
         Dummy = MoveTo(Asteroids(Window).hDC, NewLeft, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, NewTop)
         Dummy = LineTo(Asteroids(Window).hDC, NewLeft, BottomSide)
         Dummy = LineTo(Asteroids(Window).hDC, RightSide, BottomSide)
   End Select
End Sub

Sub DrawScores (ByVal Window As Integer)
   Dim ScoreString As String
   Dim CenteringStart As Integer
   Dim i As Integer

   If Score \ AWARDSHIP > LastScoreGiven Then
      NumShips = NumShips + 1
      LastScoreGiven = LastScoreGiven + 1
   End If
   Score = Score Mod 1000000
   If Score < AWARDSHIP Then
      LastScoreGiven = 0
   End If
   If Score > HiScore Then
      HiScore = Score
   End If
   ScoreString = Format$(Score, "000000")
   If NumShips < 4 And NumShips > 1 Then
      ScoreString = ScoreString & " " & String$(NumShips - 1, "^")
   ElseIf NumShips >= 4 Then
      ScoreString = ScoreString & " ^x" & Format$(NumShips - 1)
   End If
   For i = 1 To Len(ScoreString)
      DrawNumChar Window, Mid$(ScoreString, i, 1), (i * 200) / MaxX * PictWidth, 200 / MaxY * PictHeight, 200 / MaxX * PictWidth, 400 / MaxY * PictHeight
   Next i
   ScoreString = Format$(HiScore, "000000")
   CenteringStart = MaxX / 2 - (Len(ScoreString) * 200) / 2
   For i = 1 To Len(ScoreString)
      DrawNumChar Window, Mid$(ScoreString, i, 1), (CenteringStart + (i - 1) * 200) / MaxX * PictWidth, 200 / MaxY * PictHeight, 200 / MaxX * PictWidth, 400 / MaxY * PictHeight
   Next i
End Sub

Sub DrawShip (ByVal Window As Integer, ByVal ThrustOn As Integer)
   Dim RndNum As Single
   Dim SinVal As Double
   Dim CosVal As Double
   Dim i As Integer

   If Ship.X = -1 Then
      Exit Sub
   End If
   SinVal = Sin(Ship.Radians)
   CosVal = Cos(Ship.Radians)
   If Ship.ThrustOn Then
      Ship.XVel = Ship.XVel + SinVal * 10
      Ship.YVel = Ship.YVel + CosVal * 10
      If Ship.XVel < -150 Then Ship.XVel = -150
      If Ship.XVel > 150 Then Ship.XVel = 150
      If Ship.YVel < -150 Then Ship.YVel = -150
      If Ship.YVel > 150 Then Ship.YVel = 150
   Else 'Slow down ship
      If Ship.XVel > 0 Then
         Ship.XVel = Ship.XVel - 1
      End If
      If Ship.XVel < 0 Then
         Ship.XVel = Ship.XVel + 1
      End If
      If Ship.YVel > 0 Then
         Ship.YVel = Ship.YVel - 1
      End If
      If Ship.YVel < 0 Then
         Ship.YVel = Ship.YVel + 1
      End If
   End If

   Ship.X = Ship.X + Ship.XVel
   Ship.Y = Ship.Y + Ship.YVel
   
   LocateShip

   For i = 1 To 3
      ShipUFOArray(i).X = Ship.ShipArray(i).X / MaxX * PictWidth
      ShipUFOArray(i).Y = Ship.ShipArray(i).Y / MaxY * PictHeight
   Next 'i
   If Ship.RegionHandle <> 0 Then
      Dummy = DeleteObject(Ship.RegionHandle)
   End If
   Ship.RegionHandle = CreatePolygonRgn(ShipUFOArray(1), 3, ALTERNATE)
   Dummy = Polygon(Asteroids(Window).hDC, ShipUFOArray(1), 3)
   If Ship.ThrustOn Then
      ShipUFOArray(1).X = (Ship.X + 100 * CosVal - 250 * SinVal) / MaxX * PictWidth
      ShipUFOArray(1).Y = (Ship.Y - 100 * SinVal - 250 * CosVal) / MaxY * PictHeight
      RndNum = Rnd
      ShipUFOArray(2).X = (Ship.X - (250 + 200 * RndNum) * SinVal) / MaxX * PictWidth
      ShipUFOArray(2).Y = (Ship.Y - (250 + 200 * RndNum) * CosVal) / MaxY * PictHeight
      ShipUFOArray(3).X = (Ship.X - 100 * CosVal - 250 * SinVal) / MaxX * PictWidth
      ShipUFOArray(3).Y = (Ship.Y + 100 * SinVal - 250 * CosVal) / MaxY * PictHeight
      Dummy = MoveTo(Asteroids(Window).hDC, ShipUFOArray(1).X, ShipUFOArray(1).Y)
      Dummy = LineTo(Asteroids(Window).hDC, ShipUFOArray(2).X, ShipUFOArray(2).Y)
      Dummy = LineTo(Asteroids(Window).hDC, ShipUFOArray(3).X, ShipUFOArray(3).Y)
      Ship.ThrustOn = False
   End If
End Sub

Sub DrawUFO (ByVal Window As Integer)
   Dim i As Integer

   If UFO.Size = 0 And Ship.X <> -1 Then
      If Rnd * 300 / Level < Level Then
         UFO.Size = Rnd + 1
         UFO.Y = Rnd * 1 / Level * MaxY
         If Rnd >= .5 Then
            UFO.X = MaxX
            UFO.XVel = -100
         Else
            UFO.X = 0
            UFO.XVel = 45 / UFO.Size + 25
            UFO.HowLong = 0
         End If
         Bullets(5).HowLong = 0
      Else
         Exit Sub
      End If
   End If
   If UFO.Size > 0 Then
      If UFO.HowLong <= 0 Then
         UFO.HowLong = 10
         If Rnd > .15 * UFO.Size Then
            UFO.YVel = Rnd * 2 - 1
            UFO.YVel = UFO.YVel * UFO.XVel
         End If
      End If
      UFO.HowLong = UFO.HowLong - 1
      UFO.X = UFO.X + UFO.XVel
      UFO.Y = UFO.Y + UFO.YVel
      If UFO.X < 0 Or UFO.X > MaxX Then
         UFO.Size = 0
         Exit Sub
      End If
      If UFO.Y < 0 Then
         UFO.Y = MaxY
      ElseIf UFO.Y > MaxY Then
         UFO.Y = 0
      End If
      UFO.UFOArray(1).X = (UFO.X - 150 * UFO.Size)
      UFO.UFOArray(1).Y = UFO.Y
      UFO.UFOArray(2).X = (UFO.X - 100 * UFO.Size)
      UFO.UFOArray(2).Y = (UFO.Y + 75 * UFO.Size)
      UFO.UFOArray(3).X = (UFO.X + 100 * UFO.Size)
      UFO.UFOArray(3).Y = (UFO.Y + 75 * UFO.Size)
      UFO.UFOArray(4).X = (UFO.X + 150 * UFO.Size)
      UFO.UFOArray(4).Y = UFO.Y
      UFO.UFOArray(5).X = (UFO.X + 100 * UFO.Size)
      UFO.UFOArray(5).Y = (UFO.Y - 75 * UFO.Size)
      UFO.UFOArray(6).X = UFO.X
      UFO.UFOArray(6).Y = (UFO.Y - 150 * UFO.Size)
      UFO.UFOArray(7).X = (UFO.X - 100 * UFO.Size)
      UFO.UFOArray(7).Y = (UFO.Y - 75 * UFO.Size)
      For i = 1 To 7
         ShipUFOArray(i).X = UFO.UFOArray(i).X / MaxX * PictWidth
         ShipUFOArray(i).Y = UFO.UFOArray(i).Y / MaxY * PictHeight
      Next i
      If UFO.RegionHandle <> 0 Then
         Dummy = DeleteObject(UFO.RegionHandle)
      End If
      UFO.RegionHandle = CreatePolygonRgn(ShipUFOArray(1), 7, 0)
      Dummy = Polygon(Asteroids(Window).hDC, ShipUFOArray(1), 7)
      Dummy = MoveTo(Asteroids(Window).hDC, ShipUFOArray(1).X, ShipUFOArray(1).Y)
      Dummy = LineTo(Asteroids(Window).hDC, ShipUFOArray(4).X, ShipUFOArray(4).Y)
      Dummy = MoveTo(Asteroids(Window).hDC, ShipUFOArray(5).X, ShipUFOArray(5).Y)
      Dummy = LineTo(Asteroids(Window).hDC, ShipUFOArray(7).X, ShipUFOArray(7).Y)
      If Bullets(5).HowLong = 0 Then
         CreateUFOBullet
      Else
         Bullets(5).HowLong = Bullets(5).HowLong - 1
      End If
   End If
End Sub

Sub Form_Activate ()
   Me.Show
   Do
      TitleScreen
      PlayGame
   Loop
End Sub

Sub Form_Load ()
   GameStatus = Prep
   Asteroids(0).Visible = True
   Asteroids(1).Visible = False
   hBrushWhite = CreateSolidBrush(QBColor(15))
   hBrushRed = CreateSolidBrush(QBColor(12))
   hPenWhite = CreatePen(0, 0, QBColor(15))
   hPenRed = CreatePen(0, 0, QBColor(12))
   Me.ScaleMode = 3
   Asteroids(0).ScaleMode = 3
   Asteroids(1).ScaleMode = 3
   UFO.RegionHandle = 0
   Ship.RegionHandle = 0
   Randomize
   HiScore = 0
   CalcAsteroids
End Sub

Sub Form_Resize ()
   Dim i As Integer
   For i = 0 To 1
      Asteroids(i).Top = 0
      Asteroids(i).Left = 0
      Asteroids(i).Width = Me.ScaleWidth
      Asteroids(i).Height = Me.ScaleHeight
   Next 'i
   PictHeight = Asteroids(0).ScaleHeight
   PictWidth = Asteroids(0).ScaleWidth
End Sub

Sub Form_Unload (Cancel As Integer)
   Dummy = DeleteObject(hBrushWhite)
   Dummy = DeleteObject(hBrushRed)
   Dummy = DeleteObject(hPenWhite)
   Dummy = DeleteObject(hPenRed)
   If Ship.RegionHandle <> 0 Then
      Dummy = DeleteObject(Ship.RegionHandle)
   End If
   If UFO.RegionHandle <> 0 Then
      Dummy = DeleteObject(UFO.RegionHandle)
   End If
End Sub

Sub LocateShip ()
   Dim SinVal As Double
   Dim CosVal As Double

   SinVal = Sin(Ship.Radians)
   CosVal = Cos(Ship.Radians)
   
   If Ship.X < 0 Then
      Ship.X = MaxX
   End If
   If Ship.X > MaxX Then
      Ship.X = 0
   End If
   If Ship.Y < 0 Then
      Ship.Y = MaxY
   End If
   If Ship.Y > MaxY Then
      Ship.Y = 0
   End If
   Ship.ShipArray(1).X = (Ship.X + 250 * SinVal)
   Ship.ShipArray(1).Y = (Ship.Y + 250 * CosVal)
   Ship.ShipArray(2).X = (Ship.X + 150 * CosVal - 250 * SinVal)
   Ship.ShipArray(2).Y = (Ship.Y - 150 * SinVal - 250 * CosVal)
   Ship.ShipArray(3).X = (Ship.X - 150 * CosVal - 250 * SinVal)
   Ship.ShipArray(3).Y = (Ship.Y + 150 * SinVal - 250 * CosVal)
   Ship.ShipArray(4).X = (Ship.ShipArray(1).X + Ship.ShipArray(2).X) / 2
   Ship.ShipArray(4).Y = (Ship.ShipArray(1).Y + Ship.ShipArray(2).Y) / 2
   Ship.ShipArray(5).X = (Ship.ShipArray(1).X + Ship.ShipArray(3).X) / 2
   Ship.ShipArray(5).Y = (Ship.ShipArray(1).Y + Ship.ShipArray(3).Y) / 2
End Sub

Sub PlayGame ()
   Dim VisibleWindow As Integer
   Dim OtherWindow As Integer
   Dim i As Integer
   Dim NumAsteroids As Integer
   Dim DelayTime As Integer
   
   Dim NextDraw As Long



   NumShips = 3
   VisibleWindow = 0
   Level = 1
   TimerPop = False
   'Clear out any keys already in buffer
   timerScreenSwap.Interval = 250
   Do
      DoEvents
      ProcessKeys
   Loop Until TimerPop
   timerScreenSwap.Interval = 33
   DelayTime = 0
   NumAsteroids = 0
   Score = 0
   LastScoreGiven = 0
   Do
      Ship.XVel = 0
      Ship.YVel = 0
      Ship.Radians = 180 * PI / 180
      Ship.X = MaxX / 2
      Ship.Y = MaxY / 2
      GameStatus = INGAME
      Ship.ThrustOn = False
      AllowShot = 0
      AllowFire = True
      AllowHyperspace = True
      LocateShip
      Do
         'If our ship exploded, wait a while and then wait
         'until there is space to place another ship
         If Ship.X = -1 And DelayTime = -1 Then
            DelayTime = 75
         ElseIf Ship.X = -1 Then
            If (NumShips = 1 Or CheckCenterSafe() = True) And DelayTime = 0 Then
               NumShips = NumShips - 1
               DelayTime = -1
               Exit Do
            ElseIf DelayTime > 0 Then
               DelayTime = DelayTime - 1
            End If
         End If

         'If all the asteroids are destroyed, wait a while
         'before filling up the screen again
         If NumAsteroids = 0 And DelayTime = -1 Then
            DelayTime = 50
         ElseIf NumAsteroids = 0 Then
            If DelayTime = 0 Then
               Level = Level + 1
               CreateAsteroidField Level, NumAsteroids
               DelayTime = -1
            Else
               DelayTime = DelayTime - 1
            End If
         End If

         NextDraw = Time + 1
         OtherWindow = 1 - VisibleWindow
         
         ProcessKeys
         DrawScores OtherWindow
         DrawShip OtherWindow, Ship.ThrustOn
         DrawBullets OtherWindow
         DrawUFO OtherWindow
         DrawExplosions OtherWindow
         
         For i = 1 To (Level + 3) * 4
            If AsteroidField(i).Size > 0 Then
               AsteroidField(i).X = AsteroidField(i).X + AsteroidField(i).XVel
               AsteroidField(i).Y = AsteroidField(i).Y + AsteroidField(i).YVel
               DrawAsteroid OtherWindow, i
            End If
         Next 'i
         CheckCollisions NumAsteroids
         TimerPop = False
         Do
            DoEvents
         Loop Until TimerPop
         Asteroids(OtherWindow).Visible = True
         Asteroids(VisibleWindow).Visible = False
         Asteroids(VisibleWindow).Cls
         VisibleWindow = OtherWindow
         DoEvents
      Loop While GameStatus = INGAME
   Loop Until NumShips = 0 Or GameStatus <> INGAME
End Sub

Sub ProcessKeys ()
   Dim i As Integer
   'If GetAsyncKeyState(VK_ESCAPE) <> 0 Then GameStatus = INTITLE
   If GetAsyncKeyState(VK_LEFT) <> 0 Then
      If Ship.X <> -1 Then
         Ship.Radians = Ship.Radians + ShipIncrement
         If Ship.Radians > MaxRadians Then Ship.Radians = 0
      End If
   End If
   If GetAsyncKeyState(VK_UP) <> 0 Then Ship.ThrustOn = True
   If GetAsyncKeyState(VK_RIGHT) <> 0 And Ship.X <> -1 Then
      Ship.Radians = Ship.Radians - ShipIncrement
      If Ship.Radians < 0 Then Ship.Radians = MaxRadians
   End If
   If GetAsyncKeyState(VK_DOWN) <> 0 And Ship.X <> -1 Then
      If AllowHyperspace Then
         Ship.X = Rnd * 8000 + 1000
         Ship.Y = Rnd * 8000 + 1000
         Ship.XVel = 0
         Ship.YVel = 0
         AllowHyperspace = False
         If Rnd <= .1 Then
            LocateShip
            DestroyShip
         End If
      End If
   Else
      AllowHyperspace = True
   End If
   If GetAsyncKeyState(VK_SPACE) <> 0 And Ship.X <> -1 Then
      If AllowFire Then
         If AllowShot = 0 Then
            CreateBullet
            AllowShot = 3
         End If
         AllowFire = False
      End If
   Else
      AllowFire = True
   End If
End Sub

Sub timerScreenSwap_Timer ()
   Dim i As Integer
   
   TimerPop = True
   'Expire the life of a bullet
   For i = 1 To 5
      If Bullets(i).HowLong > 0 Then
         Bullets(i).HowLong = Bullets(i).HowLong - 1
      End If
   Next 'i
   If AllowShot > 0 Then
      AllowShot = AllowShot - 1
   End If
End Sub

Sub TitleScreen ()
   Dim VisibleWindow As Integer
   Dim OtherWindow As Integer
   Dim i As Integer
   Dim LetterSize As Integer
   Dim CenteringStart As Integer
   Dim Incr As Integer
   Dim Title As String
   Dim Copyright As String
   Dim AsteroidCount As Integer

   Title = "ASTEROIDS"
   Copyright = "COPYRIGHT 1996 HOWARD UMAN"

   UFO.Size = 0
   For i = 1 To 5
      Bullets(i).HowLong = 0
   Next 'i

   TitleDone = False
   VisibleWindow = 0
   timerScreenSwap.Interval = 33
   GameStatus = INTITLE
   LetterSize = 40
   Incr = 20
   Level = 5
   CreateAsteroidField Level, AsteroidCount
   NumShips = 0

   Do
      OtherWindow = 1 - VisibleWindow
      DrawScores OtherWindow
      For i = 1 To MaxAsteroids
         If AsteroidField(i).Size > 0 Then
            AsteroidField(i).X = AsteroidField(i).X + AsteroidField(i).XVel
            AsteroidField(i).Y = AsteroidField(i).Y + AsteroidField(i).YVel
            DrawAsteroid OtherWindow, i
         Else
            Exit For
         End If
      Next 'i

      If LetterSize > 600 Or LetterSize < 40 Then
         Incr = -Incr
         If LetterSize < 40 Then
            If Title = "ASTEROIDS" Then
               Title = "GAME OVER"
            Else
               Title = "ASTEROIDS"
            End If
         End If
      End If
      LetterSize = LetterSize + Incr
      CenteringStart = (MaxX - (Len(Title) + 1) * LetterSize) / 2
      For i = 0 To Len(Title) - 1
         DrawNumChar OtherWindow, Mid$(Title, i + 1, 1), (CenteringStart + i * LetterSize) / MaxX * PictWidth, PictHeight / 2 - LetterSize / MaxY * PictHeight, LetterSize / MaxX * PictWidth, (LetterSize * 2) / MaxY * PictHeight
      Next i
      CenteringStart = (MaxX - Len(Copyright) * 100) / 2
      For i = 0 To Len(Copyright) - 1
         DrawNumChar OtherWindow, Mid$(Copyright, i + 1, 1), (CenteringStart + i * 100) / MaxX * PictWidth, PictHeight - 400 / MaxY * PictHeight, 100 / MaxX * PictWidth, 200 / MaxY * PictHeight
      Next i


      TimerPop = False
      Do
         DoEvents
      Loop Until TimerPop
      Asteroids(OtherWindow).Visible = True
      Asteroids(VisibleWindow).Visible = False
      Asteroids(VisibleWindow).Cls
      VisibleWindow = OtherWindow
      DoEvents
   Loop Until TitleDone
End Sub

