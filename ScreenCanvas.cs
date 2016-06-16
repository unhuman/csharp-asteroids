using System;
using System.Collections;
using System.Drawing;

namespace Asteroids
{
	/// <summary>
	/// Summary description for ScreenCanvas.
	/// </summary>
	public class ScreenCanvas
	{
      protected ArrayList points;
      protected ArrayList pensLineColor;
      protected ArrayList polygons;
      protected ArrayList pensPolyColor;

      private Point ptLast;
      private System.Drawing.Pen penLast;
      private bool ptLastDefined;      

		public ScreenCanvas()
		{
         ptLastDefined = false;
         points = new ArrayList();
         pensLineColor = new ArrayList();
         polygons = new ArrayList();
         pensPolyColor = new ArrayList();
		}

      public void Clear()
      {
         points.Clear();
         pensLineColor.Clear();
         polygons.Clear();
         pensPolyColor.Clear();
      }

      public void Draw(System.Windows.Forms.PaintEventArgs e)
      {
         System.Drawing.Pen penDraw;
         if (points.Count % 2 == 0)
         {
            Point pt1, pt2;
            int iLinePen = 0;
            for (int i=0; i<points.Count;)
            {
               pt1 = (Point)points[i++];
               pt2 = (Point)points[i++];
               penDraw = (System.Drawing.Pen)pensLineColor[iLinePen++];
               e.Graphics.DrawLine(penDraw, pt1, pt2);               
            }
            
            for (int i=0; i<polygons.Count;i++)
            {
               Point[] poly = (Point[])polygons[i];
               penDraw = (System.Drawing.Pen)pensPolyColor[i];
               e.Graphics.DrawPolygon(penDraw, poly);
            }
         }
      }

      public void AddLine(Point ptStart, Point ptEnd, System.Drawing.Pen penColor)
      {
         points.Add(ptStart);
         points.Add(ptEnd);
         pensLineColor.Add(penColor);
         ptLastDefined = true;
         ptLast = ptEnd;
         penLast = penColor;
      }

      public void AddLine(Point ptStart, Point ptEnd)
      {
         AddLine(ptStart, ptEnd, System.Drawing.Pens.White);
      }

      public void AddLineTo(Point ptEnd)
      {
         if (ptLastDefined)
         {
            points.Add(ptLast);
            points.Add(ptEnd);
            pensLineColor.Add(penLast);
            ptLast = ptEnd;
         }
      }

      public void AddPolygon(Point[] ptArray, System.Drawing.Pen penColor)
      {
         polygons.Add(ptArray);
         pensPolyColor.Add(penColor);
      }

      public void AddPolygon(Point[] ptArray)
      {
         AddPolygon(ptArray, System.Drawing.Pens.White);
      }
	}
}
