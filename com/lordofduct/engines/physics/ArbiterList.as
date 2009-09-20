package com.lordofduct.engines.physics
{
	internal class ArbiterList
	{
		private var _arr:Array = new Array();
		
		public function ArbiterList()
		{
			
		}
		
/**
 * Properties
 */
		public function get length():int { return _arr.length; }
		
/**
 * Methods
 */
		public function add( arb:Arbiter ):void
		{
			var index:int = this.indexOf(arb);
			
			if(index < 0) _arr.push(arb);
			else
			{
				var last:int = _arr.length - 1;
				_arr[index] = _arr[last];
				_arr[last] = arb;
			}
		}
		
		public function clear():void
		{
			_arr.length = 0;
		}
		
		public function contains( arb:Arbiter ):void
		{
			return (this.indexOf(arb) != -1);
		}
		
		public function indexOf( arb:Arbiter ):int
		{
			var arbiter:Object;
			
			for( var i:int = 0; i < _arr.length; i++ )
			{
				arbiter = _arr[i];
				if(arb.equals(arbiter)) return i;
			}
			
			return -1;
		}
		
		public function remove( arb:Arbiter ):void
		{
			var index:int = this.indexOf(arb);
			
			if(index != -1) _arr.splice(index, 1);
		}
		
		public function getItem( index:int ):Arbiter
		{
			return _arr[index] as Arbiter;
		}
	}
}