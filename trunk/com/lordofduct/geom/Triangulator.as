package com.lordofduct.geom
{
	import com.lordofduct.util.Assertions;
	
	public class Triangulator
	{
		/** The accepted error value */
		private static const EPSILON:Number = 0.0000000001;
		/** The list of points to be triangulated */
		private _poly:PointList = new PointList();
		/** The list of points describing the triangles */
		private _tris:PointList = new PointList();
		/** True if we've tried to triangulate */
		private _tried:Boolean = false;
		
		/**
		 * Create a new triangulator
		 */
		public function Triangulator()
		{
			
		}
		
		/**
		 * Add a point describing the polygon to be triangulated
		 * 
		 * @param x The x coordinate of the point
		 * @param y the y coordinate of the point
		 */
		public function addPolyPoint(ix:Number, iy:Number):void
		{
			_poly.pushVertPair( ix, iy );
		}
		
		/**
		 * Cause the triangulator to split the polygon
		 * 
		 * @return True if we managed the task
		 */
		public function triangulate():Boolean
		{
			_tried = true;
			
			return process(_poly,_tris);
		}
		
		/**
		 * Get a count of the number of triangles produced
		 * 
		 * @return The number of triangles produced
		 */
		public function getTriangleCount():int
		{
			Assertions.isNotTrue( _tried, "com.lordofduct.engines.phys2d.util::Triangulator - Call triangulate() before accessing triangles", Error );
			
			return _tris.numVerts / 3;
		}
		
		/**
		 * Get a point on a specified generated triangle
		 * 
		 * @param tri The index of the triangle to interegate
		 * @param i The index of the point within the triangle to retrieve
		 * (0 - 2)
		 * @return The x,y coordinate pair for the point
		 */
		public function getTrianglePoint(tri:int, i:int):Point2D
		{
			Assertions.isNotTrue( _tried, "com.lordofduct.engines.phys2d.util::Triangulator - Call triangulate() before accessing triangles", Error );
			
			return _tris.getVert((tri*3)+i);
		
		/** 
		 * Find the area of a polygon defined by the series of points
		 * in the list
		 * 
		 * @param contour The list of points defined the contour of the polygon
		 * (Vector2f)
		 * @return The area of the polygon defined
		 */
		private static function area(contour:PointList):Number
		{
			var n:int = contour.numVerts;
	
			var A:Number = 0;
	
			for (var p:int = n - 1, q = 0; q < n; p = q++) {
				var cP:Point2D = contour.getVert(p);
				var cQ:Point2D = contour.getVert(q);
	
				A += cP.x * cQ.y - cQ.x * cP.y;
			}
			return A * 0.5;
		}
	
		/**
		 * Check if the point P is inside the triangle defined by
		 * the points A,B,C
		 * 
		 * @param Ax Point A x-coordinate
		 * @param Ay Point A y-coordinate
		 * @param Bx Point B x-coordinate
		 * @param By Point B y-coordinate
		 * @param Cx Point C x-coordinate
		 * @param Cy Point C y-coordinate
		 * @param Px Point P x-coordinate
		 * @param Py Point P y-coordinate
		 * @return True if the point specified is within the triangle
		 */
		private static function insideTriangle( Ax:Number, Ay:Number, Bx:Number, By:Number, Cx:Number, Cy:Number, Px:Number, Py:Number ):Boolean
		{
			var ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, apx:Number, apy:Number, bpx:Number, bpy:Number, cpx:Number, cpy:Number;
			var cCROSSap:Number, bCROSScp:Number, aCROSSbp:Number;
	
			ax = Cx - Bx;
			ay = Cy - By;
			bx = Ax - Cx;
			by = Ay - Cy;
			cx = Bx - Ax;
			cy = By - Ay;
			apx = Px - Ax;
			apy = Py - Ay;
			bpx = Px - Bx;
			bpy = Py - By;
			cpx = Px - Cx;
			cpy = Py - Cy;
	
			aCROSSbp = ax * bpy - ay * bpx;
			cCROSSap = cx * apy - cy * apx;
			bCROSScp = bx * cpy - by * cpx;
	
			return ((aCROSSbp >= 0) && (bCROSScp >= 0) && (cCROSSap >= 0));
		}
	
		/**
		 * Cut a the contour and add a triangle into V to describe the 
		 * location of the cut
		 * 
		 * @param contour The list of points defining the polygon
		 * @param u The index of the first point
		 * @param v The index of the second point
		 * @param w The index of the third point
		 * @param n ?
		 * @param V The array to populate with indicies of triangles
		 * @return True if a triangle was found
		 */
		private static function snip( contour:PointList, u:int, v:int, w:int, n:int, V:Array ):Boolean
		{
			var p:int;
			var Ax:Number, Ay:Number, Bx:Number, By:Number, Cx:Number, Cy:Number, Px:Number, Py:Number;
			
			Ax = contour.getVertX(V[u]);
			Ay = contour.getVertY(V[u]);
	
			Bx = contour.getVertX(V[v]);
			By = contour.getVertY(V[v]);
	
			Cx = contour.getVertX(V[w]);
			Cy = contour.getVertY(V[w]);
	
			if (EPSILON > (((Bx - Ax) * (Cy - Ay)) - ((By - Ay) * (Cx - Ax)))) {
				return false;
			}
	
			for (p = 0; p < n; p++) {
				if ((p == u) || (p == v) || (p == w)) {
					continue;
				}
	
				Px = contour.getVertX(V[p]);
				Py = contour.getVertY(V[p]);
	
				if (insideTriangle(Ax, Ay, Bx, By, Cx, Cy, Px, Py)) {
					return false;
				}
			}
	
			return true;
		}
	
		/**
		 * Process a list of points defining a polygon
		 * @param contour The list of points describing the polygon
		 * @param result The list of points describing the triangles. Groups
		 * of 3 describe each triangle 
		 * 
		 * @return True if we succeeded in completing triangulation
		 */
		private function process( contour:PointList, result:PointList ):Boolean
		{
			/* allocate and initialize list of Vertices in polygon */
	
			var n:int = contour.numVerts;
			if (n < 3)
				return false;
	
			var V:Array = new Array(n);
	
			/* we want a counter-clockwise polygon in V */
			
			var v:int;
			
			if (0 < area(contour)) {
				for (v = 0; v < n; v++)
					V[v] = v;
			} else {
				for (v = 0; v < n; v++)
					V[v] = (n - 1) - v;
			}
	
			var nv:int = n;
	
			/*  remove nv-2 Vertices, creating 1 triangle every time */
			var count:int = 2 * nv; /* error detection */
	
			for (var m:int = 0, v = nv - 1; nv > 2;) {
				/* if we loop, it is probably a non-simple polygon */
				if (0 >= (count--)) {
					//** Triangulate: ERROR - probable bad polygon!
					return false;
				}
	
				/* three consecutive vertices in current polygon, <u,v,w> */
				var u:int = v;
				if (nv <= u)
					u = 0; /* previous */
				v = u + 1;
				if (nv <= v)
					v = 0; /* new v    */
				var w:int = v + 1;
				if (nv <= w)
					w = 0; /* next     */
	
				if (snip(contour, u, v, w, nv, V)) {
					var a:int, b:int, c:int, s:int, t:int;
	
					/* true names of the vertices */
					a = V[u];
					b = V[v];
					c = V[w];
	
					/* output Triangle */
					result.pushVert(contour.getVert(a), contour.getVert(b), contour.getVert(c));
					//result.pushVert(contour.getVert(a));
					//result.pushVert(contour.getVert(b));
					//result.pushVert(contour.getVert(c));
	
					m++;
	
					/* remove v from remaining polygon */
					for (s = v, t = v + 1; t < nv; s++, t++) {
						V[s] = V[t];
					}
					nv--;
	
					/* resest error detection counter */
					count = 2 * nv;
				}
			}
	
			return true;
		}

	}
}