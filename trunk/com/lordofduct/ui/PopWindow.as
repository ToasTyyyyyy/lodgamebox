/**
 * PopWindow - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * This is the base class for PopWindow instances. You can extend it 
 * to create your own PopWindow.
 * 
 * The IPopWindow interface can also be used for this same purpose, but it 
 * too must extend some DisplayObject... preferrably an InteractiveObject for 
 * the grab and close bounds to function. It may sometimes be easier to use 
 * the interface, but others this class may be easier.
 */
package com.lordofduct.ui
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import com.lordofduct.events.SelectionEvent;
	
	public class PopWindow extends Sprite implements IPopWindow
	{
		private var _grabBounds:Rectangle;
		private var _restrictBounds:Rectangle;
		private var _closeBounds:Rectangle;
		
		private var _draggable:Boolean = false;
		private var _restricted:Boolean = false;
		
		public function PopWindow()
		{
			super();
		}
		
		public function get bounds():Rectangle
		{
			return this.getBounds(this);
		}
		
		public function set grabBounds( value:Rectangle ):void
		{
			_grabBounds = value;
		}
		public function get grabBounds():Rectangle
		{
			return _grabBounds;
		}
		
		public function set restrictBounds( value:Rectangle ):void
		{
			_restrictBounds = value;
		}
		public function get restrictBounds():Rectangle
		{
			return _restrictBounds;
		}
		
		public function set closeBounds( value:Rectangle ):void
		{
			_closeBounds = value;
		}
		public function get closeBounds():Rectangle
		{
			return _closeBounds;
		}
		
		public function set draggable(value:Boolean):void
		{
			_draggable = value;
		}
		
		public function get draggable():Boolean
		{
			return _draggable;
		}
		
		public function set restricted( value:Boolean ):void
		{
			_restricted = value;
		}
		public function get restricted():Boolean
		{
			return _restricted;
		}
		
		/**
		 * This method dispatches the close event. This is unique to PopWindow and is 
		 * not described by IPopWindow. It is a simple accessor to force the PopWindow 
		 * manager to close this window.
		 */
		public function yellCloseMe():void
		{
			this.dispatchEvent( new SelectionEvent( SelectionEvent.CLOSE, this ) );
		}
	}
}