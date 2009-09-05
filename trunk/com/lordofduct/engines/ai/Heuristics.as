package com.lordofduct.engines.ai
{
	public class Heuristics
	{
		public static const DIST_MANHATTAN:String = "distManhattan";
		public static const DIST_EUCLIDIAN:String = "distEuclidian";
		
		public function Heuristics()
		{
		}
		
		public static function getMethodFromId( id:String ):Function
		{
			switch ( id )
			{
				case Heuristics.DIST_EUCLIDIAN : return Heuristics.distEuclidian; break;
				case Heuristics.DIST_MANHATTAN : return Heuristics.distManhattan; break;
				default return Heuristics.distManhattan; break;
			}
		}
		
		public static function getIdFromMethod( funct:Function ):String
		{
			switch ( funct )
			{
				case Heuristics.distEuclidian : return Heuristics.DIST_EUCLIDIAN; break;
				case Heuristics.distManhattan : return Heuristics.DIST_MANHATTAN; break;
				default return "unknown"; break;
			}
		}
		
		/**
		 * 	Slower but much better heuristic method.
		 */
		public static function distEuclidian(n1:IAiNode, n2:IAiNode ):Number {
			return Math.sqrt(Math.pow((n1.x-n2.x),2)+Math.pow((n1.y-n2.y),2));
		}
		
		/**
		 * 	Faster, more inaccurate heuristic method
		 */
		public static function distManhattan(n1:IAiNode, n2:IAiNode ):Number {
			return Math.abs(n1.x-n2.x)+Math.abs(n1.y-n2.y);
		}
	}
}