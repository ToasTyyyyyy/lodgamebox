/**
 * DragScenario - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Written for use in the Gigo library for HeyMike Industries
 * 
 * This class facilitates dragging objects around the stage.
 * Object must extend InteractiveObject to ensure that it fires MouseEvents
 * You can suppliment an easing method for an object
 */
package com.lordofduct.ui
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import com.lordofduct.events.DragScenarioEvent;
	import com.lordofduct.util.IDisposable;
	import com.lordofduct.util.LoDDisplayObjUtils;
	
	import com.lordofduct.engines.animation.LoDTweener;
	import com.lordofduct.engines.animation.easing.Linear;
	
	public class DragScenario extends EventDispatcher implements IDisposable
	{
		private var _target:InteractiveObject;
		private var _speed:Number;
		private var _ease:Function;
		private var _offset:Point;
		
		private var _root:DisplayObject;
		
		public function DragScenario( target:InteractiveObject, speed:Number=0, ease:Function=null )
		{
			super(this);
			
			if (!(ease is Function)) ease = Linear.easeNone;
			
			_target = target;
			_speed = speed;
			_ease = ease;
		}
		
		public function get target():InteractiveObject { return _target; }
		public function get speed():Number { return _speed; }
		public function get ease():Function { return _ease; }
		
		internal function get restrictRoot():DisplayObject { return _root; }
		
		/**
		 * start dragging the target. It is advised to have the target added to the DisplayList 
		 * prior to starting the scenario.
		 * 
		 * @param offset - a point vector that describes where the mouse should sit with 
		 * respect to target's registration point. If null, the center of the target is used.
		 * 
		 * @param restrictTo - a parent DisplayObject of target to restrict updating with in. 
		 * By setting this you restrict the condition of updating the MouseEvent being fired to 
		 * occur only if the mouse is over "restrictTo". If null is passed we attempt to select 
		 * the stage, if the stage doesn't exist then the "root" of the target is selected.
		 */
		public function start( offset:Point=null, restrictTo:DisplayObject=null ):void
		{
			if (!_target.root) throw new Error("gigo.ui::DragScenario - critical error, drag scenario can not start until the target contains a root");
			
			if (!offset)
				offset = LoDDisplayObjUtils.findTransformedCenterOf( _target );
			
			if (!restrictTo)
				restrictTo = ( _target.stage ) ? _target.stage : _target.root;
			
			_offset = offset;
			_root = restrictTo;
			
			_root.addEventListener(MouseEvent.MOUSE_MOVE, updateDragHandler, false, 0, true );
			
			if (_target.stage) _target.stage.addEventListener(MouseEvent.MOUSE_UP, dispatchDragShouldStop, false, 0, true );
			else _root.addEventListener(MouseEvent.MOUSE_UP, dispatchDragShouldStop, false, 0, true );
			
			updateDragHandler();
		}
		
		public function stop():void
		{
			_root.removeEventListener(MouseEvent.MOUSE_MOVE, updateDragHandler );
			_root.removeEventListener(MouseEvent.MOUSE_UP, dispatchDragShouldStop );
			
			if (_target.stage) _target.stage.removeEventListener(MouseEvent.MOUSE_UP, dispatchDragShouldStop );
		}
		
/**
 * Drag Event Handling
 */
		private function updateDragHandler(e:MouseEvent=null):void
		{
			if (!_target.parent) return;
			
			/* var pos:Point = _root.localToGlobal( new Point( _root.mouseX, _root.mouseY ) );
			pos = pos.subtract( _offset );
			pos = _target.parent.globalToLocal( pos ); */
			
			var pos:Point = LoDDisplayObjUtils.localToLocal( new Point( _root.mouseX, _root.mouseY ), _root, _target );
			pos = pos.subtract( _offset );
			pos = LoDDisplayObjUtils.localToLocal( pos, _target, _target.parent );
			
			var dis:Number = Point.distance( pos, new Point( _target.x, _target.y ) );
			var time:Number = ( _speed ) ? dis / _speed : 0;
			var props:Object = { x:pos.x, y:pos.y };
			
			LoDTweener.instance.tweenTo( _target, ease, time, props, 0 );
			
			this.dispatchEvent( new DragScenarioEvent( DragScenarioEvent.DRAG_UPDATE, _target ) );
		}
		
		private function dispatchDragShouldStop(e:MouseEvent):void
		{
			this.dispatchEvent( new DragScenarioEvent( DragScenarioEvent.DRAG_SHOULD_STOP, _target ) );
		}
		
		
		
/**
 * Implement IDisposable
 * 
 * 
 */
		public function dispose():void
		{
			this.stop();
			
			_root = null;
			_target = null;
			_ease = null;
			_offset = null;
		}
		
		public function reengage(...args):void
		{
			//TODO
		}
	}
}