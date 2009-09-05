package com.lordofduct.geom
{
	import com.lordofduct.util.Assertions;
	
	import flash.geom.Point;
	
	public class Triangle extends Polygon2D
	{
		public function Triangle( a:*, b:*, c:* )
		{
			super(3);
			this.pushVert(a, b, c);
		}
	}
}