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
		private var _obj:Object;
		
		public function TweenerEvent(type:String, tweenedObj:Object, pos:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_obj = tweenedObj;
			_pos = pos;
		}
		
		public function get tweenedObject():Object { return _obj; }
		
		/**
		 * value representing percent complete from 0 -> 1
		 */
		public function get position():Number { return _pos; }
		
		
		override public function clone():Event
		{
			return new TweenerEvent(this.type, this.tweenedObject, this.position, this.bubbles, this.cancelable);
		}
	}
}