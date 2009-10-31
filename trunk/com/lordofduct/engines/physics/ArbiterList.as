package com.lordofduct.engines.physics
{
	internal class ArbiterList
	{
		private var _list:Array = new Array();
		
		public function ArbiterList()
		{
			
		}
		
/**
 * Properties
 */
		public function get length():int { return _list.length; }
		
/**
 * Methods
 */
		public function add( arb:Arbiter ):void
		{
			var index:int = this.indexOf(arb);
			
			if(index < 0) _list.push(arb);
			else
			{
				var last:int = _list.length - 1;
				_list[index] = _list[last];
				_list[last] = arb;
			}
		}
		
		public function clear():void
		{
			_list.length = 0;
		}
		
		public function contains( arb:Arbiter ):Boolean
		{
			return (this.indexOf(arb) != -1);
		}
		
		public function indexOf( arb:Arbiter ):int
		{
			var arbiter:Arbiter;
			
			for( var i:int = 0; i < _list.length; i++ )
			{
				arbiter = _list[i] as Arbiter;
				if(arb.equals(arbiter)) return i;
			}
			
			return -1;
		}
		
		public function remove( arb:Arbiter ):void
		{
			var index:int = this.indexOf(arb);
			
			if(index != -1) _list.splice(index, 1);
		}
		
		public function getItem( index:int ):Arbiter
		{
			return _list[index] as Arbiter;
		}
		
		public function arbiterExistsFor( obj:IPhysicalAttrib ):Array
		{
			var arr:Array = new Array();
			
			for each ( var arb:Arbiter in _list )
			{
				if( arb.relatesTo( obj ) ) arr.push( arb );
			}
			
			return (arr.length) ? arr : null;
		}
	}
}