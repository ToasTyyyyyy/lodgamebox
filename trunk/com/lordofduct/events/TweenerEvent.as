package com.lordofduct.events
{
	import flash.events.Event;

	public class TweenerEvent extends Event
	{
		public static const TWEEN_START:String = "tweenStart";
		public static const TWEEN_UPDATE:String = "tweenUpdate";
		public static const TWEEN_PAUSE:String = "tweenPause";
		public static const TWEEN_RESUME:String = "tweenResume";
		public static const TWEEN_COMPLETE:String = "tweenComplete";
		
		private var _pos:Number;
		
		public function TweenerEvent(type:String, pos:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_pos = pos;
		}
		
		/**
		 * value representing percent complete from 0 -> 1
		 */
		public function get position():Number { return _pos; }
	}
}