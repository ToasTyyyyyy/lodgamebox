/**
 * SFXEvent - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * Event object used by the ISFX package. A large robust package 
 * for handling a varied array of sound scenarios.
 * 
 * The SFXEvent class really doesn't add a lot of functionality to the Event class. 
 * It merely includes definitions for events that can occur in it.
 */
package com.lordofduct.events
{
	import flash.events.Event;

	public class SFXEvent extends Event
	{
		public static const PLAY:String = "play";
		public static const STOP:String = "stop";
		public static const PAUSE:String = "pause";
		public static const RESUME:String = "resume";
		public static const LOOP:String = "loop";
		public static const COMPLETE:String = "complete";
		public static const TRACK_CHANGE:String = "trackChange";
		
		public function SFXEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new SFXEvent( this.type, this.bubbles, this.cancelable );
		}
	}
}