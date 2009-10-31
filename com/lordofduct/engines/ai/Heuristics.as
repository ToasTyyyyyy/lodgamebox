package com.lordofduct.engines.ai
{
	import com.lordofduct.util.Assertions;
	
	public class Heuristics
	{
		public function Heuristics()
		{
			Assertions.throwError( "com.lordofduct.engines.ai::Heuristics - can not instantiate static member class." );
		}
		
		/**
		 * distManhattan - Fast but innacurate distance heuristic
		 */
		static public function distManhattan( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			return Math.abs(x1 - x2) + Math.abs(y1 - y2);
		}
		
		/**
		 * distEuclidian - Slow but accurate distance heuristic
		 */
		static public function distEuclidian( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt( dx * dx + dy * dy );
		}
		
		/**
		 * distEuclidianSquared - Fast semi-accurate distance heuristic. The only issue with this one is it treats distances as the square of itself.
		 */
		static public function distEuclidianSquared( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return dx * dx + dy * dy;
		}
	}
}