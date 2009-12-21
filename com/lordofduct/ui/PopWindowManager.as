/**
 * PopWindowManager - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * Singleton enforced
 * 
 * This class supports adding IPopWindows to a DisplayObjectContainer and controlling its actions.
 * 
 * The sould purpose of this class is to enforce that a window is placed in the container above all other 
 * DisplayObjects in that container. Through the construction params you can set it draggable, and force it to the top 
 * of the displayList at all times if wanted.
 * 
 * The manager will then close the window when either the "closeBounds" are clicked or when the IPopWindow dispatches 
 * a SelectionEvent.CLOSE event.
 * 
 * To allow for extensibility all bounds are defined as Rectangle properties of the IPopWindow interface. This way if 
 * you want to alter the shape of the PopWindow for animation or other effects it doesn't effect the "area" of interactivity. 
 * Instead you can update these properties to change its area of interactivity. This does create some complexity to creating 
 * unique IPopWindows (especially when implementing the interface as opposed to extending PopWindow), but it allows for more 
 * freedom in creativity.
 * 
 * You can pass regular old DisplayObjects as PopWindows. BUT there is no interactivity with the window. It merely shows the 
 * DisplayObject and waits for the SelectionEvent.CLOSE event to occur. No dragging, no always on top, no closeBounds. 
 * Furthermore if the object is scaled or rotated at all, the centering of it may not look correct.
 * 
 * TODO - add animated opening and closing.
 * 
 * WARNING - you can add and remove DisplayObject's from the container while the container has a pop window in it. 
 * Emptying it completely haults the process of the PopWindowManager. This Manager attempts to capture the event of it 
 * being removed and will cancel any further actions. But doing so can cause a memory leak of some sort (it's an untested 
 * feature is what I'm getting at). So for all intensive purposes, do try not to completely clear ALL items from a container 
 * that has active IPopWindows present in it.
 * 
 * This also goes for the container object. If it gets lost in memory at any point due to garbage collection (containers are held 
 * with a weak reference) the same problem may occur.
 * 
 */
package com.lordofduct.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import com.lordofduct.events.DragScenarioEvent;
	import com.lordofduct.events.SelectionEvent;
	import com.lordofduct.util.LoDMath;
	import com.lordofduct.util.LoDDisplayObjUtils;
	
	import com.lordofduct.util.SingletonEnforcer;
	
	public class PopWindowManager extends EventDispatcher
	{
		/**
		 * Enforce that this is a Singleton
		 * Utilizes the Guttershark method of Singleton Enforcement. Alter this section 
		 * to change the Singleton enforcement method.
		 */
		private static var _inst:PopWindowManager;
		
		public static function get instance():PopWindowManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(PopWindowManager);
			return _inst;
		}
		
		public function PopWindowManager()
		{	
			SingletonEnforcer.assertSingle(PopWindowManager);
		}
		
/**
 * Class Definition
 */
		private var _windows:Array = new Array();
		private var _winToContainer:Dictionary = new Dictionary(true);
		private var _winToDrag:Dictionary = new Dictionary();
		
		private var _contToTopWins:Dictionary = new Dictionary(true);
		
		/**
		 * Adds the IPopWindow to the displayList where container is the topMost container it is contained in. 
		 * Generally you will be using the "stage" as this container.
		 * 
		 * @window - the IPopWindow instance to be asserted. The window is held with a strong reference so it will not 
		 * leave memory.
		 * 
		 * @container - the DisplayObjectContainer that holds the IPopWindow. The container is held with a weak reference, 
		 * you must ensure it stays in memory through out the duration. If the container is lost through garbage colleciton 
		 * the window completes itself just like a SelectionEvent.CLOSE event fired.
		 * 
		 * @alwaysOnTop - forces this window to remain on top of the displayList of the container. If multiple popwindows are 
		 * placed in the same Container and set to stay on top then the most recent one interacted with will be left on top 
		 * of all others.
		 * 
		 * @position - a position to open the IPopWindow at. If null it is centered with in the BoundingBox of the container.
		 * 
		 */
		public function assertPopWindow(window:DisplayObject, 
										container:DisplayObjectContainer, 
										alwaysOnTop:Boolean=false, 
										position:Point=null ):void
		{
			if(!window || !container) throw new Error("gigo.ui::PopWindowManager - window and container must be non-null");
			
			if(_windows.indexOf(window) < 0) _windows.push(window);
			_winToContainer[window] = container;
			
			setPopWindowHandlers( window as IPopWindow, container, alwaysOnTop );
			
			if (!position)
			{
				position = new Point();
				var crect:Rectangle = container.getBounds(container);
				var wrect:Rectangle = (window is IPopWindow) ? IPopWindow(window).bounds : window.getBounds(window);
				
				var mat:Matrix = DisplayObject(window).transform.matrix;
				mat.tx = mat.ty = 0;
				wrect = LoDMath.transformRectByMatrix( wrect, mat );
				
				position.x = crect.x + ( crect.width - wrect.width ) / 2;
				position.y = crect.y + ( crect.height - wrect.height ) / 2;
			}
			
			window.x = position.x;
			window.y = position.y;
			container.addChild( window );
			
			window.addEventListener(SelectionEvent.CLOSE, closeEventHandler, false, 0, true );
		}
		
		public function isHandling( window:DisplayObject ):Boolean
		{
			return Boolean( _windows.indexOf( window ) >= 0 );
		}
/**
 * Private Interface
 */
		private function setPopWindowHandlers( window:IPopWindow, container:DisplayObjectContainer, alwaysOnTop:Boolean=false ):void
		{
			if (!window) return;
			
			window.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler, false, 0, true );
			window.addEventListener(MouseEvent.CLICK, checkCloseHandler, false, 0, true );
			
			if(alwaysOnTop)
			{
				(_contToTopWins[container]) ? _contToTopWins[container].push(window) : _contToTopWins[container] = [window];
				container.addEventListener(Event.ADDED, checkWindowOnTop, false, 0, true );
			}
		}
		
		/**
		 * Close the window from view
		 */
		public function closeWindow( window:DisplayObject ):void
		{
			if (!window) return;
			
			//remove it from the container
			var cont:DisplayObjectContainer = _winToContainer[window];
			if(cont && cont.contains(window)) cont.removeChild(window);
			
			//stop drag if it's being dragged
			var drag:DragScenario = _winToDrag[window];
			if(drag)
			{
				drag.stop();
				drag.removeEventListener(DragScenarioEvent.DRAG_UPDATE, updateDragHandler );
				drag.removeEventListener(DragScenarioEvent.DRAG_SHOULD_STOP, stopDragHandler );
			}
			
			//remove the reference to the window
			var index:int = _windows.indexOf( window );
			if (index >= 0) _windows.splice( index, 1 );
			
			//remove all other references
			window.removeEventListener(MouseEvent.MOUSE_DOWN, startDragHandler );
			window.removeEventListener(MouseEvent.CLICK, checkCloseHandler );
			window.removeEventListener(SelectionEvent.CLOSE, closeEventHandler );
			delete _winToContainer[window];
			delete _winToDrag[window];
			
			//finally remove it's ontop assertion
			var arr:Array = _contToTopWins[ cont ];
			if (arr && arr.indexOf(window) >= 0)
			{
				arr.splice( arr.indexOf(window), 1);
				if (!arr.length)
				{
					delete _contToTopWins[ cont ];
					cont.removeEventListener(Event.ADDED, checkWindowOnTop);
				}
			}
			
			this.dispatchEvent( new SelectionEvent( SelectionEvent.CLOSE, window ) );
		}
		
		private function forceTopOfList( obj:DisplayObject, cont:DisplayObjectContainer ):void
		{
			if(!obj) return;
			
			var wins:Array = _contToTopWins[cont];
			
			if (!wins) return;
			if (!wins.length)
			{
				delete _contToTopWins[cont];
				return;
			}
			
			var index:int = wins.indexOf(obj);
			if (index >= 0 && index < wins.length - 1)
			{
				wins.splice(index, 1 );
				wins.push(obj);
				_contToTopWins[cont] = wins;
			} else {
				var arr:Array = wins.concat();
				while( arr.length ) cont.addChild( arr.shift() );
			}
		}
		
/**
 * Event Listeners
 */
		/**
		 * If and when the IPopWindow says to close it, then close it
		 */
		private function closeEventHandler(e:SelectionEvent):void
		{
			closeWindow( e.currentTarget as DisplayObject );
		}
		
		/**
		 * When the mouse button get's pushed down, check to see if it was in the 
		 * bounds of the grab box. If so start dragging it.
		 */
		private function startDragHandler(e:MouseEvent):void
		{
			var window:IPopWindow = e.currentTarget as IPopWindow;
			
			if (!window || !window.draggable || _winToDrag[window] || !(window is InteractiveObject)) return;
			
			var ix:Number = DisplayObject(window).mouseX;
			var iy:Number = DisplayObject(window).mouseY;
			
			if (!window.testIfHitGrabArea(ix,iy)) return;
			
			var drag:DragScenario = new DragScenario(window as InteractiveObject);
			_winToDrag[window] = drag;
			
			var doref:DisplayObject = window as DisplayObject;
			var offset:Point = LoDDisplayObjUtils.findTransformedPointOf( doref, new Point( doref.mouseX, doref.mouseY ) );
			var cont:DisplayObjectContainer = _winToContainer[window];
			cont.addChild(doref);
			forceTopOfList( doref, cont );
			
			drag.start( offset );
			drag.addEventListener(DragScenarioEvent.DRAG_UPDATE, updateDragHandler, false, 0, true );
			drag.addEventListener(DragScenarioEvent.DRAG_SHOULD_STOP, stopDragHandler, false, 0, true );
		}
		
		private function updateDragHandler(e:DragScenarioEvent):void
		{
			var drag:DragScenario = e.currentTarget as DragScenario;
			var window:IPopWindow = drag.target as IPopWindow;
			
			//are we even going to check for boundaries
			if (!window || !window.restrictBounds || !window.restricted ) return;
			
			var full:Rectangle = window.restrictBounds.clone();
			var sub:Rectangle = LoDMath.transformRectByMatrix( window.bounds, DisplayObject(window).transform.matrix );
			
			//if the subBounds are inside fullBounds pass
			if (full.containsRect( sub )) return;
			
			var hor:Number = Math.max(full.left - sub.left, 0) + Math.min(full.right - sub.right, 0);
			var ver:Number = Math.max(full.top - sub.top, 0) + Math.min(full.bottom - sub.bottom, 0);
			
			DisplayObject(window).x += hor;
			DisplayObject(window).y += ver;
		}
		
		private function stopDragHandler(e:DragScenarioEvent):void
		{
			var drag:DragScenario = e.currentTarget as DragScenario;
			
			delete _winToDrag[drag.target];
			
			drag.stop();
			drag.removeEventListener(DragScenarioEvent.DRAG_UPDATE, updateDragHandler );
			drag.removeEventListener(DragScenarioEvent.DRAG_SHOULD_STOP, stopDragHandler );
			drag.dispose();
		}
		
		/**
		 * When the mouse clicks the window check to see if it was in the close bounds 
		 * and close it if it was.
		 */
		private function checkCloseHandler(e:MouseEvent):void
		{
			var window:IPopWindow = e.currentTarget as IPopWindow;
			
			if (!window) return;
			
			var ix:Number = DisplayObject(window).mouseX;
			var iy:Number = DisplayObject(window).mouseY;
			
			if (window.testIfHitClose(ix,iy))
			{
				closeWindow( window as DisplayObject);
			}
		}
		
		/**
		 * Checks to make sure the window is on top if the window is set to always be on top
		 */
		private function checkWindowOnTop(e:Event):void
		{
			var obj:DisplayObject = e.target as DisplayObject;
			var cont:DisplayObjectContainer = e.currentTarget as DisplayObjectContainer;
			
			if (!obj || !cont) return;
			if (obj == cont) return;
			
			forceTopOfList( obj, cont );
		}
	}
}