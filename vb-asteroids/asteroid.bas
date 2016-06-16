Option Explicit

Type Coord       ' This is the type structure for the x and y
   X As Integer  ' coordinates for the polygonal region.
   Y As Integer
End Type

'Function Prototypes associated with Polygon drawing
Declare Function CreatePolygonRgn Lib "GDI" (lpPoints As Coord, ByVal nCount As Integer, ByVal nPolyFillMode As Integer) As Integer
Declare Function Polygon Lib "gdi" (ByVal hDC As Integer, lpPoints As Any, ByVal nCount As Integer) As Integer
Declare Function Ellipse Lib "gdi" (ByVal hDC As Integer, ByVal nLeftRect As Integer, ByVal nTopRect As Integer, ByVal nRightRect As Integer, ByVal nBottomRect As Integer) As Integer
Declare Function FillRgn Lib "gdi" (ByVal hDC As Integer, ByVal hRgn As Integer, ByVal hBrush As Integer) As Integer
Declare Function CreateSolidBrush Lib "GDI" (ByVal crColor As Long) As Integer
Declare Function CreatePen Lib "GDI" (ByVal nPenStyle As Integer, ByVal nWidth As Integer, ByVal crColor As Long) As Integer
Declare Function GetStockObject Lib "gdi" (ByVal nIndex As Integer) As Integer
Declare Function SelectObject Lib "gdi" (ByVal hDC As Integer, ByVal hdgiobj As Integer) As Integer
Declare Function MoveTo Lib "GDI" (ByVal hDC As Integer, ByVal X As Integer, ByVal Y As Integer) As Long
Declare Function LineTo Lib "GDI" (ByVal hDC As Integer, ByVal X As Integer, ByVal Y As Integer) As Integer
Declare Function PtInRegion Lib "GDI" (ByVal hRgn As Integer, ByVal X As Integer, ByVal Y As Integer) As Integer
Declare Function DeleteObject Lib "GDI" (ByVal hObject As Integer) As Integer
Declare Function GetAsyncKeyState Lib "User" (ByVal vKey As Integer) As Integer
Declare Function GetKeyState Lib "User" (ByVal vKey As Integer) As Integer

Global Const ALTERNATE = 1 ' ALTERNATE and WINDING are
Global Const WINDING = 2   ' constants for FillMode.
Global Const BLACKBRUSH = 4' Constant for brush type.

Global Const VK_ESCAPE = &H1B
Global Const VK_SPACE = &H20
Global Const VK_LEFT = &H25
Global Const VK_UP = &H26
Global Const VK_RIGHT = &H27
Global Const VK_DOWN = &H28

Type AsteroidType
   X As Integer
   Y As Integer
   XVel As Integer
   YVel As Integer
   Size As Integer
End Type

Type BulletType
   X As Integer
   Y As Integer
   XVel As Integer
   YVel As Integer
   HowLong As Integer
End Type

Type ShipType
   X As Integer
   Y As Integer
   ShipArray(5) As Coord 'Corners & 2 MidPoints
   XVel As Integer
   YVel As Integer
   Radians As Double
   ThrustOn As Integer
   RegionHandle As Integer
End Type

Type UFOType
   X As Integer
   Y As Integer
   UFOArray(10) As Coord 'Corners and 1 MidPoint (bottom center)
   XVel As Integer
   YVel As Integer
   HowLong As Integer
   Size As Integer
   RegionHandle As Integer
End Type

Type ExplosionType
   X As Integer
   Y As Integer
   HowLong As Integer
End Type

Type ExplosionPieceType
   XVel As Integer
   YVel As Integer
End Type


Global Const BULLETLIFE = 35
Global Const EXPLOSIONLIFE = 15
Global Const MaxRadians = 359 * 3.141593 / 180
Global Const ShipIncrement = MaxRadians / 40

