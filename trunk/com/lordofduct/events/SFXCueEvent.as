package com.lordofduct.events
{
	import flash.events.Event;

	public class SFXCueEvent extends Event
	{
		static public const CUE_MARK:String = "cueMark";
		
		private var _alias:String;
		
		public function SFXCueEvent(type:String, ali:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_alias = ali;
		}
		
		public function get alias():String { return _alias; }
		
		override public function clone():Event
		{
			return new SFXCueEvent( this.type, this.alias, this.bubbles, this.cancelable );
		}
	}
}