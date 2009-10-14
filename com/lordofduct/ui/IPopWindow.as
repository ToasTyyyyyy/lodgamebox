/**
 * IPopWindow - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * This Interface facilitates defining a pop up window that is draggable. 
 * It enforces certain rules the IPopWindow must abide. This allows non-PopWindow 
 * typed objects to implement the interface of a PopWindow. Bar in mind all IPopWindow's
 * must have some type of DisplayObject to use as a visual. PopWindow's receive a "target" 
 * object that can be used as the "visual" data, it acts very similar to the "target" param of 
 * the EventDispatcher.
 * 
 * It is used in corrolation with the PopWindowManager Singleton to place the object on the stage 
 * above all other objects. It overrides all commands until it is closed (param controllable). The 
 * IPopWindow needs to dispatch the SelectionEvent.CLOSE event to close itself.
 * 
 */
package com.lordofduct.ui
{
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	public interface IPopWindow extends IEventDispatcher
	{
		/**
		 * The bounding box of the PopWindow with respect 
		 * to the PopWindow. Instead of the PopManager 
		 * using "getBounds()" method it allows the PopWindow 
		 * to decide what the bounds of it will be. By default 
		 * the PopWindow class just uses "getBounds(this)" (see PopWindow.as).
		 */
		function get bounds():Rectangle
		
		/**
		 * boundaries of the PopWindow that can be clicked to drag
		 * with resepect to the PopWindow itself
		 */
		function set grabBounds( value:Rectangle ):void
		function get grabBounds():Rectangle
		
		/**
		 * boundaries to keep the PopWindow within
		 * with respect to the container
		 */
		function set restrictBounds( value:Rectangle ):void
		function get restrictBounds():Rectangle
		
		/**
		 * boundaries of the PopWindow that can be clicked to close it
		 * with respect to the PopWindow itself
		 */
		function set closeBounds( value:Rectangle ):void
		function get closeBounds():Rectangle
		
		/**
		 * is the window draggable? If no dragBounds are present 
		 * the window is considered un-draggable.
		 */
		function set draggable( value:Boolean ):void
		function get draggable():Boolean
		
		/**
		 * If and when the restrictBounds property of the view is present 
		 * it will attempt to keep the "bounds" with in the area of 
		 * the "restrictBounds" with respect to its container.
		 * */
		function set restricted( value:Boolean ):void
		function get restricted():Boolean
	}
}