package com.lordofduct.ui
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public dynamic class MouseCursorManager extends Proxy
	{
		private static var _inst:MouseCursorManager;
		
		public static function get instance():MouseCursorManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(MouseCursorManager);
			
			return _inst;
		}
		
		public function MouseCursorManager()
		{
			SingletonEnforcer.assertSingle(MouseCursorManager);
		}
		
/**
 * Class Definition
 */
		private var _stage:Stage;
		private var _cursors:Dictionary = new Dictionary();
		private var _currCursor:MouseCursor = null;
		
		public function init( stg:Stage ):void
		{
			_stage = stg;
		}
		
		public function createCursor( idx:String, view:DisplayObject, pnt:Point=null, ease:Function=null, speed:uint=100 ):void
		{
			this.registerCursor( new MouseCursor(idx, view, pnt, ease, speed) );
		}
		
		public function registerCursor( cursor:MouseCursor ):void
		{
			_cursors[cursor.id] = cursor;
		}
		
		public function destroyCursor( idx:String ):void
		{
			if(!this.isManaging(idx)) return;
			
			var cursor:MouseCursor = _cursors[idx];
			cursor.dispose();
			delete _cursors[idx];
		}
		
		public function removeCursor( idx:String ):void
		{
			delete _cursors[idx];
		}
		
		public function isManaging( idx:String ):Boolean
		{
			return Boolean( _cursors[idx] );
		}
		
		public function getCursor( idx:String ):MouseCursor
		{
			return _cursors[idx];
		}
/**
 * cursor display
 */
		public function assertCursor(idx:*):void
		{
			Assertions.notNil(_stage, "com.lordofduct.ui::MouseCursorManager - mouse cursor can not be manipulated until MouseCursorManager has been initialized, please run init() method to initialize.", Error );
			
			var cursor:MouseCursor;
			if(idx is MouseCursor) cursor = idx as MouseCursor;
			if(idx is String) cursor = this.getCursor(idx);
			if(!cursor)
			{
				this.showDefaultCursor();
				return;
			}
			
			//show this cursor in stage
			this.hideCursor(_currCursor);
			_currCursor = cursor;
			cursor.view.x = _stage.mouseX;
			cursor.view.y = _stage.mouseY;
			_stage.addChild(cursor.view);
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, updateCursorPosition, false, 0, true );
			_stage.addEventListener(Event.ADDED_TO_STAGE, forceCursorToTop, false, 0, true );
			Mouse.hide();
		}
		
		public function showDefaultCursor():void
		{
			Assertions.notNil(_stage, "com.lordofduct.ui::MouseCursorManager - mouse cursor can not be manipulated until MouseCursorManager has been initialized, please run init() method to initialize.", Error );
			
			//assure no registered cursor is visible in stage
			//show the standard Mouse cursor
			
			this.hideCursor(_currCursor);
			Mouse.show();
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateCursorPosition );
			_stage.removeEventListener(Event.ADDED_TO_STAGE, forceCursorToTop );
		}
		
		public function hideCursor(idx:*):void
		{
			Assertions.notNil(_stage, "com.lordofduct.ui::MouseCursorManager - mouse cursor can not be manipulated until MouseCursorManager has been initialized, please run init() method to initialize.", Error );
			
			var cursor:MouseCursor;
			if(idx is MouseCursor) cursor = idx as MouseCursor;
			if(idx is String) cursor = this.getCursor(idx);
			if(!cursor) return;
			
			//stop cursor from being updated and remove it from the stage
			if (_stage.contains(cursor.view)) _stage.removeChild(cursor.view);
			if (cursor == _currCursor)
			{
				_currCursor = null;
				showDefaultCursor();
			}
		}
		
		public function getCurrentCursor():MouseCursor
		{
			Assertions.notNil(_stage, "com.lordofduct.ui::MouseCursorManager - mouse cursor can not be manipulated until MouseCursorManager has been initialized, please run init() method to initialize.", Error );
			
			return _currCursor;
		}
		
/**
 * Event Listeners
 */		
		private function updateCursorPosition(e:MouseEvent):void
		{
			if(!_currCursor)
			{
				this.showDefaultCursor();
				return;
			}
			
			//Update the position of the current cursor if any
			var ix:Number = _stage.mouseX - _currCursor.offset.x;
			var iy:Number = _stage.mouseY - _currCursor.offset.y;
			
			if(_currCursor.useEase)
			{
				var pos:Point = new Point( _currCursor.view.x, _currCursor.view.y );
				var dist:Number = Point.distance( pos, new Point(ix,iy) );
				var dur:Number = dist / _currCursor.easeSpeed;
				
				//TODO: perform tween, need to set up tween engine
				//instead of:
				dur = LoDMath.clamp( 1 / dur, 1 );
				
				_currCursor.view.x = ix * dur - _currCursor.offset.x;
				_currCursor.view.y = iy * dur - _currCursor.offset.y;
			} else {
				_currCursor.view.x = ix - _currCursor.offset.x;
				_currCursor.view.y = iy - _currCursor.offset.y;
			}
		}
		
		private function forceCursorToTop(e:Event):void
		{
			if(!_currCursor)
			{
				this.showDefaultCursor();
				return;
			}
			
			var obj:DisplayObject = e.target as DisplayObject;
			if(obj.parent != _stage) return;
			
			_stage.addChild(_currCursor.view);
		}
		
/**
 * Proxy overrides
 */
		flash_proxy override function callProperty(methodName:*, ...args):*
		{
			trace("com.lordofduct.utils::MouseCursorManager - Method {"+methodName+"} not found.");
			return null;
		}
		
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			var bool:Boolean = delete _cursors[name];
			return bool;
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			return _cursors[name];
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			return Boolean( _cursors[name] );
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			trace("com.lordofduct.utils::MouseCursorManager - Property {" + name + "} can not be set, create properties using the factory methods supplied.");
		}
	}
}