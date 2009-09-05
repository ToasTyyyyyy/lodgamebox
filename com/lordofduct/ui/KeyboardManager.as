package com.lordofduct.ui
{
	import com.lordofduct.events.UInputEvent;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class KeyboardManager extends EventDispatcher
	{
		private static var _inst:KeyboardManager;
		
		public static function get instance():KeyboardManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(KeyboardManager);
			
			return _inst;
		}
		
		public function KeyboardManager()
		{
			SingletonEnforcer.assertSingle(KeyboardManager);
		}
/**
 * Class Definition
 */
		private var _stage:Stage;
		private var _downs:Array = new Array();
		
		public function init(stg:Stage):void
		{
			_stage = stg;
			
			var corrupted:Boolean = (Capabilities.os.toLowerCase().indexOf("linux") != -1);
			
			if(!corrupted)
			{
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKeyDownCondition, false, 0, true );
				_stage.addEventListener(KeyboardEvent.KEY_UP, checkKeyUpCondition, false, 0, true );
			} else {
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKeyDownConditionCorrupted, false, 0, true );
				_stage.addEventListener(KeyboardEvent.KEY_UP, checkKeyUpConditionCorrupted, false, 0, true );
				
				_dict = new Dictionary();
				_timer = new Timer(100,1);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerEventListener, false, 0, true );
			}
			
			_stage.addEventListener(FocusEvent.FOCUS_OUT, onTargetFocusOut, false, 0, true );
		}
		
		public function isKeyDown(keyCode:int):Boolean
		{
			return _downs.indexOf(keyCode) >= 0;
		}
/**
 * Event Listeners
 */
		private function checkKeyDownCondition(e:KeyboardEvent):void
		{
			var ev:UInputEvent;
			
			if(_downs.indexOf(e.keyCode) < 0)
			{
				_downs.push(e.keyCode);
				
				ev = UInputEvent.convertKeyboardEvent(e, UInputEvent.INPUT_PRESS);
			} else {
				ev = UInputEvent.convertKeyboardEvent(e, UInputEvent.INPUT_HOLD);
			}
			
			this.dispatchEvent(ev.clone());
			IEventDispatcher(e.target).dispatchEvent(ev);
		}
		
		private function checkKeyUpCondition(e:KeyboardEvent):void
		{
			var index:int = _downs.indexOf(e.keyCode);
			if(index >= 0)
			{
				_downs.splice(index,1);
				var ev:UInputEvent = UInputEvent.convertKeyboardEvent(e, UInputEvent.INPUT_RELEASE);
				this.dispatchEvent(ev.clone());
				IEventDispatcher(e.target).dispatchEvent(ev);
			}
		}
		
		private function onTargetFocusOut(e:FocusEvent):void
		{
			if(e.eventPhase != EventPhase.AT_TARGET) return;
			
			_downs.length = 0;
			this.dispatchEvent(new UInputEvent( UInputEvent.INPUT_RESET ));
			_stage.dispatchEvent(new UInputEvent( UInputEvent.INPUT_RESET ));
		}
/**
 * Corrupted Event Listeners
 */
		private var _dict:Dictionary;
		private var _timer:Timer;
		
		private function checkKeyDownConditionCorrupted(e:KeyboardEvent):void
		{
			delete _dict[e.keyCode];
			
			var ev:UInputEvent;
			
			if(_downs.indexOf(e.keyCode) < 0)
			{
				_downs.push(e.keyCode);
				
				ev = UInputEvent.convertKeyboardEvent(e, UInputEvent.INPUT_PRESS);
			} else {
				ev = UInputEvent.convertKeyboardEvent(e, UInputEvent.INPUT_HOLD);
			}
			
			this.dispatchEvent(ev);
			IEventDispatcher(e.target).dispatchEvent(ev);
		}
		
		private function checkKeyUpConditionCorrupted(e:KeyboardEvent):void
		{
			_dict[e.keyCode] = e;
			
			_timer.reset();
			_timer.start();
		}
		
		private function timerEventListener(e:TimerEvent):void
		{
			for each(var kbev:KeyboardEvent in _dict)
			{
				var index:int = _downs.indexOf(kbev.keyCode);
				if(index >= 0)
				{
					_downs.splice(index,1);
					var ev:UInputEvent = UInputEvent.convertKeyboardEvent(kbev, UInputEvent.INPUT_RELEASE);
					this.dispatchEvent(ev.clone());
					IEventDispatcher(kbev.target).dispatchEvent(ev);
				}
			}
		}
	}
}