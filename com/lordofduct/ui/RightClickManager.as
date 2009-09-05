/**
 * RightClickManager - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Singleton Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This class is intended to be used along with the JavaScript object: LoDRightClickTrap.js
 * 
 * When using the javascript object MUST be present, and the flash player must be allowed script access. 
 * If this is not done, then ExternalInterface will fail to connect and a trace will fire to inform 
 * you of such.
 * 
 * 
 * Example:
 * 
 * first ensure that LoDRightClickTrap.js is running in the container.
 * 
 * Then in your code you can say:
 * 
 * 

RightClickManager.instance.start(stage);//only have to started ONCE...
myObj.addEventListener(RightClickManager.RIGHT_CLICK, handler);//the MouseEvent types are stored in RightClickManager for easy access

function handler(e:MouseEvent):void
{
	trace(e.target);
}

 * 
 * 
 */
package com.lordofduct.ui
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	public class RightClickManager
	{
		private static var _inst:RightClickManager;
		
		public static function get instance():RightClickManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(RightClickManager);
			
			return _inst;
		}
		
		public function RightClickManager()
		{
			SingletonEnforcer.assertSingle(RightClickManager);
		}
/**
 * Static Members
 */
		public static const RIGHT_MOUSE_DOWN:String = "rightMouseDown";
		public static const RIGHT_MOUSE_UP:String = "rightMouseUp";
		public static const RIGHT_CLICK:String = "rightClick";
/**
 * Class Definition
 */
		private var _stage:Stage;
		private var _recentDown:InteractiveObject;
		private var _simple:Boolean = false;
		
		/**
		 * Start listening for right click events. If ExternalInterface is not available a trace fires informing you 
		 * that it has not started.
		 * 
		 * @param stg - a reference to the stage used for referencing the DisplayList
		 * @param simple - should the manager pay attention to the "mouseEnabled" and "mouseChildren" properties 
		 * of the InteractiveObjects.
		 */
		public function init( stg:Stage, simple:Boolean=false ):Boolean
		{
			//Assertions dependency, if you don't want it, uncomment the next line, and comment out the Assertions line
			//if(!stg) throw new Error("com.lordofduct.ui::RightClickManager - stage reference must be non-null.");
			Assertions.notNil( stg, "com.lordofduct.ui::RightClickManager - stage reference must be non-null." );
			
			_stage = stg;
			_simple = simple;
			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback( "rightMouseButtonTrap", handleExternalTrap );
				return true;
			}
			else
			{
				trace( "com.lordofduct.ui::RightClickManager - ExternalInterface is not available");
				return false;
			}
		}
		
		/**
		 * GETTER/SETTER
		 * 
		 * should the manager pay attention to the "mouseEnabled" and "mouseChildren" properties 
		 * of the InteractiveObjects.
		 */
		public function get assertsMouseEnabled():Boolean { return !_simple; }
		public function set assertsMouseEnabled( value:Boolean ):void { _simple = !value; }
		
	/**
	 * External Traps
	 */
		private function handleExternalTrap(type:String=null):void
		{	
			var targ:InteractiveObject = (_simple) ? trapTopMostChildNaive() : trapTopMostChild();
			type = type.toLowerCase();
			
			switch(type)
			{
				case "mousedown" : forceMouseDown( targ ); break;
				case "mouseup" : forceMouseUp( targ ); break;
			}
		}
		
	/**
	 * Force Events
	 */
		private function forceMouseDown( targ:InteractiveObject ):void
		{
			if (!targ) return;
			
			var type:String = RIGHT_MOUSE_DOWN;
			var bubbles:Boolean = true;
			var cancelable:Boolean = false;
			var localX:Number = targ.mouseX;
			var localY:Number = targ.mouseY;
			var relatedObject:InteractiveObject = targ;
			var ctrlKey:Boolean = false;
			var altKey:Boolean = false;
			var shiftKey:Boolean = false;
			var buttonDown:Boolean = true;
			var delta:int = 0;
			
			var evt:MouseEvent = new MouseEvent( type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta );
			targ.dispatchEvent( evt );
			
			//set the most recent object to have mouse down done
			_recentDown = targ;
		}
		
		private function forceMouseUp( targ:InteractiveObject ):void
		{
			if (!targ) return;
			
			var type:String = RIGHT_MOUSE_UP;
			var bubbles:Boolean = true;
			var cancelable:Boolean = false;
			var localX:Number = targ.mouseX;
			var localY:Number = targ.mouseY;
			var relatedObject:InteractiveObject = targ;
			var ctrlKey:Boolean = false;
			var altKey:Boolean = false;
			var shiftKey:Boolean = false;
			
			var evt:MouseEvent = new MouseEvent( type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey );
			targ.dispatchEvent( evt );
			
			//if target was the last mouse down, then dispatch click
			if( targ == _recentDown) forceMouseClick(targ);
			_recentDown = null;
		}
		
		private function forceMouseClick( targ:InteractiveObject ):void
		{
			if (!targ) return;
			
			var type:String = RIGHT_CLICK;
			var bubbles:Boolean = true;
			var cancelable:Boolean = false;
			var localX:Number = targ.mouseX;
			var localY:Number = targ.mouseY;
			var relatedObject:InteractiveObject = targ;
			var ctrlKey:Boolean = false;
			var altKey:Boolean = false;
			var shiftKey:Boolean = false;
			
			var evt:MouseEvent = new MouseEvent( type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey );
			targ.dispatchEvent( evt );
		}
		
	/**
	 * Top most InteractiveObject trap
	 */
		/**
		 * Returns the top most InteractiveObject while ignoring mouseEnabled and mouseChildren
		 */
	 	private function trapTopMostChildNaive():InteractiveObject
	 	{
	 		var arr:Array = _stage.getObjectsUnderPoint( new Point( _stage.mouseX, _stage.mouseY ) );
	 		
	 		while(arr.length)
	 		{
		 		var targ:DisplayObject = arr.pop();
		 		if(!(targ is InteractiveObject)) targ = targ.parent;
		 		if(targ) return targ as InteractiveObject;
	 		}
	 		
	 		return _stage;
	 	}
	 	
	 	/**
	 	 * Returns the top most InteractiveObject that hasn't been mouse disabled by either its own property 
	 	 * or my a parents mouseChildren property.
	 	 */
	 	private function trapTopMostChild():InteractiveObject
	 	{	
	 		var arr:Array = _stage.getObjectsUnderPoint( new Point( _stage.mouseX, _stage.mouseY ) );
	 		
	 		if(!arr.length) return _stage;
	 		
	 		while( arr.length )
	 		{
	 			var targ:DisplayObject = arr.pop() as DisplayObject;
	 			if (targ && !(targ is InteractiveObject)) targ = targ.parent;
	 			if(!targ) continue;
	 			
	 			var possible:InteractiveObject = mouseCancelled(targ as InteractiveObject);//figure out if targ is mouse disabled at all
	 			if( possible == targ ) return possible;//if targ is NOT mouseDisabled in any way then it is top most, stop now
	 			else if(doesContainSome(arr,possible as DisplayObjectContainer)) continue;//if possible contains any of the remaining elements, continue
	 			else return possible;//otherwise possible is the result
	 		}
	 		
	 		//if no possible object in the array was accessible, then just return the container
	 		return _stage;
	 	}
	 	
	 	/**
	 	 * when a child is not mouseEnabled by a parent or itself, then it returns the next top most relative parent.
	 	 */
	 	private function mouseCancelled( child:InteractiveObject ):InteractiveObject
		{
			while(!child.mouseEnabled) child = child.parent;
			
			var par:DisplayObjectContainer = child.parent;
			
			while(par)
			{
				if (!par.mouseChildren)
				{
					child = par;
					while (!child.mouseEnabled)
					{
						child = child.parent;
						par = child as DisplayObjectContainer;
					}
				}
				par = par.parent;
			}
			
			return child;
		}
		
		/**
		 * Does some DisplayObjectContainer contain any DisplayObject of an Array
		 */
		private function doesContainSome(arr:Array, par:DisplayObjectContainer ):Boolean
		{
			for( var i:int = 0; i < arr.length; i++ )
			{
				if(par.contains(arr[i])) return true;
			}
			
			return false;
		}
	}
}