package com.lordofduct.geom
{
	public class Quadrilateral extends Polygon2D
	{
		public function Quadrilateral(a:*, b:*, c:*, d:*)
		{
			super(4);
			
			this.pushVert(a, b, c, d);
		}
		
	}
}