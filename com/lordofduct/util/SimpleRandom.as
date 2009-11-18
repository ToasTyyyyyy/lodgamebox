package com.lordofduct.util
{
	import flash.utils.ByteArray;
	
	public class SimpleRandom
	{
		/**
		 * X_n+1 = (aX_n + c) mod m
		 * where:
		 * m = _mode
		 * a = _mult
		 * c = _incr
		 * X_0 = _seed
		 */
		
		private var _mode:int;
		private var _mult:int;
		private var _incr:int;
		private var _seed:int;
		
		public function SimpleRandom( seed:int=-1, increment:int=0 )
		{
			_mode = int.MAX_VALUE;
			_mult = 16807;//7^5
			_incr = increment;
			
			if(seed < 0)
			{
				var dt:Date = new Date();
				seed = dt.milliseconds;
			}
			
			_seed = seed % _mode;
		}
		
		public function next():int
		{
			_seed = (_mult * _seed + _incr) % _mode;
			return _seed;
		}
		
		public function nextBytes( bar:ByteArray ):void
		{
			var block:int = this.next();
			bar.writeByte( block >>> 24 );
			bar.writeByte( block >>> 16 );
			bar.writeByte( block >>> 8 );
			bar.writeByte( block );
		}
		
		public function nextDouble():Number
		{
			return this.next() / _mode;
		}
	}
}