/**
 * DragScenarioEvent - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * Event associated with IDragScenario and siblings.
 */
package com.lordofduct.events
{
	import flash.display.InteractiveObject;
	import flash.events.Event;

	public class DragScenarioEvent extends Event
	{
		public static const DRAG_START:String = "dragStart";
		public static const DRAG_UPDATE:String = "dragUpdate";
		public static const DRAG_COMPLETE:String = "dragComplete";
		public static const DRAG_SHOULD_STOP:String = "dragShouldStop";
		
		private var _drag:InteractiveObject;
		
		public function DragScenarioEvent(type:String, draggedItem:InteractiveObject, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_drag = draggedItem;
		}
		
		public function get drag():InteractiveObject { return _drag; }
		
		override public function clone():Event
		{
			return new DragScenarioEvent( this.type, this.drag, this.bubbles, this.cancelable );
		}
		
	}
}