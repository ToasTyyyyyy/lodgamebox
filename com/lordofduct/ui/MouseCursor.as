package com.lordofduct.ui
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.IDisposable;
	import com.lordofduct.util.IIdentifiable;
	import com.lordofduct.util.IVisibleObject;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.geom.Point;

	public class MouseCursor implements IVisibleObject, IIdentifiable, IDisposable
	{
		private var _id:String;
		private var _view:DisplayObject;
		private var _offset:Point;
		private var _ease:Function;
		private var _speed:uint = 100;
		private var _useEase:Boolean = false;
		
		public function MouseCursor( idx:String, obj:DisplayObject, pnt:Point=null, easeFunct:Function=null, speed:uint=100 )
		{
			Assertions.notNil(idx,"com.lordofduct.ui::Cursor - id param must be non-null");
			Assertions.notNil(obj, "com.lordofduct.ui::Cursor - obj param must be non-null");
			
			if (!pnt) pnt = new Point();
			
			_id = idx;
			_view = obj;
			_offset = pnt;
			_ease = easeFunct;
			_speed = speed;
			
			this.invalidate();
		}
		
		public function set offset(value:Point):void { _offset = value; }
		public function get offset():Point { return _offset; }
		
		public function set ease(value:Function):void { _ease = value; }
		public function get ease():Function { return _ease; }
		
		/**
		 * Speed of ease in pixels per second
		 */
		public function set easeSpeed(value:uint):void { _speed = value; }
		public function get easeSpeed():uint { return _speed; }
		
		public function set useEase(value:Boolean):void { _useEase = value; }
		public function get useEase():Boolean { return (_ease is Function) ? _useEase : false; this.invalidate(); }
		
		public function show():void
		{
			MouseCursorManager.instance.assertCursor(this);
		}
		
		public function hide():void
		{
			MouseCursorManager.instance.hideCursor(this);
		}
		
		private function invalidate():void
		{
			if(_ease is Function) _useEase = true;
			
			if (_view is InteractiveObject) InteractiveObject(_view).mouseEnabled = false;
			if (_view is DisplayObjectContainer) DisplayObjectContainer(_view).mouseChildren = false;
			
			if (MouseCursorManager.instance.getCurrentCursor() == this) MouseCursorManager.instance.assertCursor(this);
		}
/**
 * IVisibleObject interface
 */
		public function get view():DisplayObject{ return _view; }
		public function set view(value:DisplayObject):void{ _view = value; this.invalidate(); }
/**
 * IIdentifiable interface
 */
		public function get id():String { return _id; }
		public function set id(value:String):void { _id = value; }
/**
 * IDisposable interface
 */
		public function reengage(...args):void
		{
			var idx:String = args[0], obj:DisplayObject = args[1];
			var pnt:Point = args[2] as Point;
			var easeFunct:Function = args[3] as Function;
			var speed:uint = (isNaN(args[4])) ? 100 : args[4];
			
			Assertions.notNil(idx,"com.lordofduct.ui::Cursor - id param must be non-null");
			Assertions.notNil(obj, "com.lordofduct.ui::Cursor - obj param must be non-null");
			
			if (!pnt) pnt = new Point();
			
			_id = idx;
			_view = obj;
			_offset = pnt;
			_ease = easeFunct;
			_speed = speed;
			if(_ease is Function) _useEase = true;
			
			if (_view is InteractiveObject) InteractiveObject(_view).mouseEnabled = false;
			if (_view is DisplayObjectContainer) DisplayObjectContainer(_view).mouseChildren = false;
		}
		
		public function dispose():void
		{
			if(MouseCursorManager.instance.isManaging(_id)) MouseCursorManager.instance.removeCursor(_id);
			
			_id = null;
			_view = null;
			_offset = null;
			_ease = null;
			_useEase = false;
		}
	}
}