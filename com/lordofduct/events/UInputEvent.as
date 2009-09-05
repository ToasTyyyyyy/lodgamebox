package com.lordofduct.events
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	public class UInputEvent extends Event
	{
		public static const INPUT_PRESS:String = "inputPress";
		public static const INPUT_RELEASE:String = "inputRelease";
		public static const INPUT_HOLD:String = "inputHold";
		public static const INPUT_RESET:String = "inputReset";
		
		private var _altKey:Boolean;
		private var _ctrlKey:Boolean;
		private var _shiftKey:Boolean;
		
		private var _code:*;
		
		public function UInputEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, actCode:*=null, alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false )
		{
			super(type, bubbles, cancelable);
			
			_altKey = alt;
			_ctrlKey = ctrl;
			_shiftKey = shift;
			_code = actCode;
		}
		
		public function get altKey():Boolean { return _altKey; }
		public function get ctrlKey():Boolean { return _ctrlKey; }
		public function get shiftKey():Boolean { return _shiftKey; }
		public function get code():* { return _code; }
		
		override public function clone():Event
		{
			return new UInputEvent(this.type, this.bubbles, this.cancelable, this.code, this.altKey, this.ctrlKey, this.shiftKey);
		}
		
		public static function convertKeyboardEvent(e:KeyboardEvent, newType:String):UInputEvent
		{
			return new UInputEvent(newType, e.bubbles, e.cancelable, e.keyCode, e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		public static function convertMouseEvent(e:MouseEvent, newType:String):UInputEvent
		{
			var but:String = (e.type.toLowerCase().indexOf("right") != -1) ? "leftButton" : "rightButton";
			return new UInputEvent(newType, e.bubbles, e.cancelable, but, e.altKey, e.ctrlKey, e.shiftKey);
		}
	}
}