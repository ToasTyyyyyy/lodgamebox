package com.lordofduct.geom
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Quadrilateral extends Polygon2D
	{
		public function Quadrilateral(a:*, b:*, c:*, d:*)
		{
			super(4);
			
			this.pushVert(a, b, c, d);
		}
		
		public static function quadFromRectangle( rect:Rectangle ):Quadrilateral
		{
			var tl:Point = rect.topLeft;
			var br:Point = rect.bottomRight;
			
			return new Quadrilateral( tl, new Point( br.x, tl.y ), br, new Point( tl.x, br.y ) );
		}
	}
}