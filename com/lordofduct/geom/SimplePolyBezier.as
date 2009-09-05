package com.lordofduct.geom
{
	import flash.geom.Point;
	
	public class SimplePolyBezier
	{
		private var _points:Array = new Array();
		
		public function SimplePolyBezier(...args)
		{
			if(args && args.length) this.addPoints(args);
		}
		
		public function addPoint( pnt:Point ):void
		{
			if(!pnt) return;
			
			_points.push(pnt);
		}
		
		public function addPoints( arr:Array ):void
		{
			for each( var pnt:Point in arr )
			{
				if(pnt) this.addPoint(pnt);
			}
		}
		
		public function getPosition( t:Number ):Point
		{
			if(_points.length < 1) throw new Error("com.lordofduct.util.geom::SimplePolyBezier - the bezier curve must contain at minimum of 1 points");
			if(_points.length == 1) return _points[0].clone();
			
			var a1:Array = _points.slice();
			var a2:Array = new Array();
			
			while(a1.length > 1)
			{
				while(a1.length > 1)
				{
					var p1:Point = a1.shift() as Point;
					var p2:Point = a1[0] as Point;
					var p3:Point = Point.interpolate(p1,p2,t);
					a2.push(p3);
				}
				a1.splice(0,a1.length);
				a1 = a2.splice(0,a2.length);
			}
			
			return a1[0] as Point;
		}
	}
}