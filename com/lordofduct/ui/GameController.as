package com.lordofduct.ui
{
	import com.lordofduct.util.IDisposable;
	import com.lordofduct.util.IIdentifiable;
	
	import flash.events.EventDispatcher;
	
	public class GameController extends EventDispatcher implements IDisposable, IIdentifiable
	{
		private var _id:String;
		
		public function GameController( idx:String )
		{
			_id = idx;
		}

/**
 * IDisposable Interface
 */
		public function reengage(...args):void
		{
			var idx:String = args[0];
			_id = idx;
		}
		
		public function dispose():void
		{
			_id = null;
		}
/**
 * IIdentifiable Interface
 */
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
	}
}