package com.lordofduct.events
{
	import flash.events.Event;

	public class AniEvent extends Event
	{
		public static const ANI_COMPLETE:String = "aniComplete";
		
		public function AniEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}