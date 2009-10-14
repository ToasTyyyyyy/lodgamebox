/**
 * SelectionEvent - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * This custom event facilitates custom selections. It's a rather generic 
 * event that can be used to commit several types of "selections" made inside 
 * of Objects.
 * 
 * Two properties are included for use along with the selection event.
 * 
 * item - the related object that was selected. It is up to you what the related object is. 
 * For instance in a collection item could be the item in the collection selected.
 * 
 * params - an Object of params to be passed along with the selection if needed. It can be left null 
 * if not necessary. For instance again if in a collection an item is selected, and there is a quantity 
 * of said item, then you can pass this as a property of the "params" Object.
 */
package com.lordofduct.events
{
	import flash.events.Event;

	public class SelectionEvent extends Event
	{
		public static const SELECTION_MADE:String = "selectionMade";
		public static const SELECTION_FAIL:String = "selectionFail";
		public static const ALTERATION_MADE:String = "alterationMade";
		public static const ALTERATION_FAIL:String = "alterationFail";
		public static const CLOSE:String = "close";
		
		private var _item:Object;
		private var _params:Object;
		
		public function SelectionEvent(type:String, item:Object, params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_item = item;
			_params = params;
		}
		
		public function get item():Object { return _item; }
		public function get params():Object { return _params; }
		
		override public function clone():Event
		{
			return new SelectionEvent( this.type, this.item, this.params, this.bubbles, this.cancelable );
		}
		
	}
}