// ActionScript file
package com.lordofduct.util.supplemental
{
	private function polyContains( pnt:Point, ...verts ):Boolean
	{
		var i:int, j:int, p1x:Number, p1y:Number, p2x:Number, p2y:Number, rtn:Boolean = false;
		for( i = 0; i < verts.length; i++ )
		{
			j = i + 1;
			j %= verts.length;
			
			p1x = verts[j].x;
			p1y = verts[j].y;
			p2x = verts[i].x;
			p2y = verts[i].y;
			
			if( (p1y > pnt.y ) != (p2y > pnt.y)   &&   pnt.x < (p2x - p1x) * (pnt.y - p1y) / (p2y - p1y) + p1x ) rtn = !rtn;
		}
		
		return rtn;
	}
}