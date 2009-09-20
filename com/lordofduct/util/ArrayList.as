package com.lordofduct.util
{
	public class ArrayList
	{
		private var _arr:Array;
		
		public function ArrayList(source:Array = null)
		{
			this.source = source;
		}
/**
 * Properties
 */
		public function get length():int { return _arr.length; }
		
		public function get source():Array { return _arr.slice(); }
		public function set source(value:Array):void { _arr = (value) ? value.slice(), new Array();
/**
 * Methods
 */
		public function addAll(addList:ArrayList):void
		{
			_arr = _arr.concat( addList.source );
		}
		
		public function addAllAt(addList:ArrayList, index:int):void
		{
			var params:Array = addList.source;
			params.unshift(0);
			params.unshift(index);
			_arr.splice.apply(_arr, params);
		}
		
		public function addItem(item:Object):void
		{
			_arr.push(item);
		}
		
		public function addItemAt(item:Object, index:int):void
		{
			_arr.splice(index, 0, item );
		}
		
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return _arr[index];
		}
		
		public function getItemIndex(item:Object):int
		{
			return _arr.indexOf(item);
		}
		
		public function removeAll():void
		{
			_arr.length = 0;
		}
		
		public function removeItem(item:Object):Boolean
		{
			var index:int = _arr.indexOf(item);
			
			if(index < 0) return false;
			else
			{
				_arr.splice(index,1);
				return true;
			}
		}
		
		public function removeItemAt(index:int):Object
		{
			return _arr.splice(index,1)[0];
		}
		
		public function setItemAt(item:Object, index:int):Object
		{
			_arr.splice(index,0,item);
		}
		
		public function toArray():Array
		{
			return _arr.slice();
		}
		
		public function toString():String
		{
			return _arr.toString();
		}
	}
}