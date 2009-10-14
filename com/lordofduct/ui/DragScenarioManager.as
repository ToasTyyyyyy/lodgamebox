/**
 * DragScenarioManager - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * This class facilitates managing dragging multiple objects around the stage.
 * Object must extend InteractiveObject to ensure that it fires MouseEvents
 * You can suppliment an easing method for an object
 */
package com.lordofduct.ui
{
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import com.lordofduct.events.DragScenarioEvent;
	import com.lordofduct.engines.animation.easing.Linear;
	import com.lordofduct.util.SingletonEnforcer;
	
	public class DragScenarioManager extends EventDispatcher
	{
		private static var _inst:DragScenarioManager;
		
		public static function get instance():DragScenarioManager
		{
			if (!_inst) _inst=SingletonEnforcer.gi(DragScenarioManager);
			return _inst;
		}
		
		public function DragScenarioManager()
		{
			SingletonEnforcer.assertSingle(DragScenarioManager);
		}
		
		
		private var _draggables:Array = new Array();
		private var _dragToScenario:Dictionary = new Dictionary();
		private var _dragToEase:Dictionary = new Dictionary( true );
		private var _dragToSpeed:Dictionary = new Dictionary();
		
/**
 * Public Interface
 */	
		/**
		 * Number of draggable items in the list
		 */
		public function get numDraggable():int { return _draggables.length; }
		
		/**
		 * Checks if this is managing the InteractiveObject in question
		 */
		public function manages( obj:InteractiveObject ):Boolean { return Boolean( _draggables.indexOf( obj ) >= 0 ); }
		
		/**
		 * Retrive an InteractiveObject from it's index in the list
		 */
		public function getDraggableAt( index:int ):InteractiveObject { return _draggables[ index ]; }
		
		/**
		 * Returns a Boolean describing if the manager currently contains a DragScenario that is dragging an InteractiveObject
		 */
		public function isDragging( obj:InteractiveObject ):Boolean
		{
			return Boolean( _dragToScenario[ obj ] );
		}
		
		/**
		 * Retrieve the active scenario for an Interactive Object if any
		 */
		public function getScenarioFor( obj:InteractiveObject ):DragScenario
		{
			return _dragToScenario[ obj ];
		}
		
		/**
		 * get or set the speed for a given InteractiveObject if it exists
		 */
		public function getSpeedFor( obj:InteractiveObject ):Number { return var _dragToSpeed[ obj ]; }
		public function setSpeedFor( obj:InteractiveObject, speed:Number ):void
		{
			if (!this.manages( obj )) return;
			
			_dragToSpeed[ obj ] = speed;
		}
		
		/**
		 * get or set the ease method for a given InteractiveObject if it exists
		 */
		public function getEaseFor( obj:InteractiveObject ):Function { return _dragToEase[ obj ]; }
		public function setEaseFor( obj:InteractiveObject, ease:Function ):void
		{
			if (!this.manages( obj )) return;
			
			_dragToEase[ obj ] = ease;
		}
		
		/**
		 * Add an InteractiveObject to be managed
		 * @obj - the InteractiveObject to watch for dragging
		 * @speed - speed to drag the object at measured in global pixels/second. 0 == no easing
		 * @ease - the easing function to use, if null Linear.easeNone is used
		 */
		public function addDraggable( obj:InteractiveObject, speed:Number=50, ease:Function=null ):void
		{
			if (!obj) return;
			
			if (!ease) ease = Linear.easeNone;
			
			_dragToEase[obj] = ease;
			_dragToSpeed[obj] = speed;
			obj.addEventListener( MouseEvent.MOUSE_DOWN, startDragHandler, false, 0, true );
			
			if (_draggables.indexOf( obj ) < 0) _draggables.push( obj );
		}
		
		/**
		 * Stops managing an InteractiveObject for dragging
		 * @obj - the InteractiveObject to stop listening for
		 */
		public function removeDraggable( obj:InteractiveObject ):void
		{
			if (!obj) return;
			
			var index:int = _draggables.indexOf( obj );
			
			if (index >= 0) _draggables.splice( index, 1 );
			
			obj.removeEventListener( MouseEvent.MOUSE_DOWN, startDragHandler );
			this.stopDrag( obj );
			
			delete _dragToEase[ obj ];
			delete _dragToSpeed[ obj ];
		}
		
/**
 * ...
 */
		public function startDrag( obj:InteractiveObject ):DragScenario
		{
			if (!this.manages( obj )) throw new Error("gigo.ui::DragScenarioManager - only objects that are being managed can be added to a drag scenario");
			
			if (this.isDragging( obj )) return this.getScenarioFor( obj );
			
			var scenario:DragScenario = new DragScenario( obj, this.getSpeedFor( obj ), this.getEaseFor( obj ) );
			scenario.start();
			
			_dragToScenario[ obj ] = scenario;
			
			this.dispatchEvent( new DragScenarioEvent( DragScenarioEvent.DRAG_START, obj ) );
			
			return scenario;
		}
		
		public function stopDrag( obj:InteractiveObject ):void
		{
			var scenario:DragScenario = this.getScenarioFor( obj );
			
			if (scenario)
			{
				delete _dragToScenario[ obj ];
				scenario.removeEventListener( DragScenarioEvent.DRAG_SHOULD_STOP, stopDragHandler );
				scenario.removeEventListener( DragScenarioEvent.DRAG_UPDATE, bubbleOutUpdateEvent );
				scenario.dispose();
				this.dispatchEvent( new DragScenarioEvent( DragScenarioEvent.DRAG_COMPLETE, obj ) );
			}
		}
		
/**
 * Event Handling for dragging
 */
		private function startDragHandler(e:MouseEvent):void
		{
			var targ:InteractiveObject = e.currentTarget as InteractiveObject;
			
			if (!targ) return;
			if (!this.manages(targ)) return;
			
			var scenario:DragScenario = this.startDrag( targ );
			
			scenario.addEventListener( DragScenarioEvent.DRAG_SHOULD_STOP, stopDragHandler, false, 0, true );
			scenario.addEventListener( DragScenarioEvent.DRAG_UPDATE, bubbleOutUpdateEvent, false, 0, true );
		}
		
		private function bubbleOutUpdateEvent(e:DragScenarioEvent):void
		{
			this.dispatchEvent( e.clone() );
		}
		
		private function stopDragHandler(e:DragScenarioEvent):void
		{
			var scenario:DragScenario = e.currentTarget as DragScenario;
			
			if (!scenario) return;
			
			this.stopDrag( scenario.target );
		}
	}
}