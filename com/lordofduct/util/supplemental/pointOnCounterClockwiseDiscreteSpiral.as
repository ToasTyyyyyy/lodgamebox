// ActionScript file
package com.lordofduct.util.supplemental
{
	import flash.geom.Point;
	
	public function pointOnCounterClockwiseDiscreteSpiral( n:int, dir:String="N" ):Point
	{
		var n_rt:Number = Math.sqrt(n);
		var m:int = Math.floor( Math.sqrt(n_rt) );
		var negCheck:int = (dir == "S" || dir == "E" ) ? Math.pow(-1, m + 1) : Math.pow(-1, m);
		var odd:int = (Math.floor(2 * n_rt) % 2);
		var part1:Number = (n - m * (m + 1));
		var part2:Number = (dir="N" || dir="S") ? Math.ceil( m / 2 ) : Math.floor( m / 2 );
		var pnt:Point = new Point();
		pnt.x = negCheck * ( part1 * !odd + part2 );
		pnt.y = negCheck * ( part1 * odd + part2 );
		return pnt;
	}
}