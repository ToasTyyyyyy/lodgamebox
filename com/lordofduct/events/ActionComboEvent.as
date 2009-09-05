package com.lordofduct.events
{
	import flash.events.Event;

	public class ActionComboEvent extends Event
	{
		public static const ACTION_ACTIVATED:String = "actionActivated";
		public static const ACTION_REPEAT:String = "actionRepeat";
		public static const ACTION_DEACTIVATED:String = "actionDeactivated";
		
		private var _act:String;
		
		public function ActionComboEvent(type:String, act:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_act = act;
		}
		
		public function get action():String { return _act; }
		
		override public function clone():Event
		{
			return new ActionComboEvent( this.type, this.action, this.bubbles, this.cancelable );
		}
	}
}