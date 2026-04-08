using System;
using System.Collections.Generic;
using System.Drawing;
using Raylib_cs;
using RlColor = Raylib_cs.Color;

namespace Asteroids
{
	/// <summary>
	/// Summary description for ScreenCanvas.
	/// </summary>
	public class ScreenCanvas
	{
      protected List<Point> points;
      protected List<RlColor> pensLineColor;
      protected List<Point[]> polygons;
      protected List<RlColor> pensPolyColor;

      private Point ptLast;
      private RlColor penLast;
      private bool ptLastDefined;      

		public ScreenCanvas()
		{
         ptLastDefined = false;
         points = new List<Point>();
         pensLineColor = new List<RlColor>();
         polygons = new List<Point[]>();
         pensPolyColor = new List<RlColor>();
		}

      public void Clear()
      {
         points.Clear();
         pensLineColor.Clear();
         polygons.Clear();
         pensPolyColor.Clear();
      }

      public void Draw()
      {
         if (points.Count % 2 == 0)
         {
            int iLinePen = 0;
            for (int i=0; i<points.Count;)
            {
               Point pt1 = points[i++];
               Point pt2 = points[i++];
               RlColor color = pensLineColor[iLinePen++];
               Raylib.DrawLine(pt1.X, pt1.Y, pt2.X, pt2.Y, color);               
            }
            
            for (int i=0; i<polygons.Count;i++)
            {
               Point[] poly = polygons[i];
               RlColor color = pensPolyColor[i];
               for (int j = 0; j < poly.Length; j++)
               {
                  int next = (j + 1) % poly.Length;
                  Raylib.DrawLine(poly[j].X, poly[j].Y, poly[next].X, poly[next].Y, color);
               }
            }
         }
      }

      public void AddLine(Point ptStart, Point ptEnd, RlColor penColor)
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
         AddLine(ptStart, ptEnd, RlColor.White);
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

      public void AddPolygon(Point[] ptArray, RlColor penColor)
      {
         polygons.Add(ptArray);
         pensPolyColor.Add(penColor);
      }

      public void AddPolygon(Point[] ptArray)
      {
         AddPolygon(ptArray, RlColor.White);
      }
	}
}
