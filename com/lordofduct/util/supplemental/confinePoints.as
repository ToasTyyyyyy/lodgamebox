// ActionScript file
package com.lordofduct.util.supplemental
{
	import flash.geom.Rectangle;
	
	public function confinePoints(...verts):Rectangle
		{
			var xp:Array = new Array();
			var yp:Array = new Array();
			while(verts.length)
			{
				var pnt:Object = verts.shift();
				if(pnt.hasOwnProperty("x") && pnt.hasOwnProperty("y"))
				{
					xp.push(pnt.x);
					yp.push(pnt.y);
				}
			}
			
			var left:Number = Math.min.apply(null, xp);
			var right:Number = Math.max.apply(null, xp);
			var top:Number = Math.min.apply(null, yp);
			var bottom:Number = Math.max.apply(null, yp);
		
			return new Rectangle( left, top, right - left, bottom - top );
		}
}