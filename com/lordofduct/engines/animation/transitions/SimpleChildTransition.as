package com.lordofduct.engines.animation.transitions
{
	import com.lordofduct.engines.animation.IChildTransition;
	import com.lordofduct.events.TweenerEvent;
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;

	public class SimpleChildTransition extends EventDispatcher implements IChildTransition
	{
		private var _startChild:DisplayObject;
		private var _endChild:DisplayObject;
		private var _cont:DisplayObjectContainer;
		
		private var _delay:Number;
		private var _dur:Number;
		private var _pos:Number;
		
		private var _paused:Boolean = false;
		
		public function SimpleChildTransition( cont:DisplayObjectContainer, start:DisplayObject, end:DisplayObject, dur:Number=0, startDelay:Number=0 )
		{
			super();
			
			Assertions.notNil( cont, "com.lordofduct.engines.animation.transitions:: IChildTransition - relatedContainer must be non-null." );
			_startChild = start;
			_endChild = end;
			_cont = cont;
			
			_dur = dur;
			_delay = startDelay;
			_pos = 0;
		}
		
	/**
	 * ITransition / ITween Interface
	 */
		public function get delay():Number { return _delay; }
		
		public function get duration():Number { return _dur; }
		
		public function get passed():Number { return LoDMath.clamp( _pos - _delay, _dur ); }
		
		public function get position():Number { return this.passed / _dur; }
		
		public function get property():String { return "childTransition"; }
		
		public function get target():Object { return _cont; }
		
		public function get startChild():DisplayObject { return _startChild; }
		
		public function get endChild():DisplayObject { return _endChild; }
		
		public function get relatedContainer():DisplayObjectContainer { return _cont; }
/**
 * Public Methods
 */
	/**
	 * ITransition / ITween Interface
	 */
		public function update(dt:Number):Boolean
		{
			if(_paused) return false;
			
			var op:Number = _pos;
			_pos = _pos + dt;
			var t:Number = LoDMath.clamp(_pos - _delay, _dur );
			
			if( _pos < _delay ) return false;
			else if ( op <= _delay && t > 0 )
			{
				this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_START, t ) );
			}
			
			if ( _pos - _delay >= _dur )
			{
				this.swapChildren();
				this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_COMPLETE, 1 ) );
				return true;
			} else {
				return false;
			}
		}
		
		public function pause():void
		{
			if(_paused) return;
			
			_paused = true;
			this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_PAUSE, this.position ) );
		}
		
		public function resume():void
		{
			if(!_paused) return;
			
			_paused = false;
			this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_RESUME, this.position ) );
		}
		
		public function invert():void
		{
			//TODO
		}
		
	/**
	 * IDisposable interface
	 */
		public function dispose():void
		{
			_endChild = null;
			_startChild = null;
			_cont = null;
		}
		
		public function reengage(...args):void
		{
			//TODO
		}
		
	/**
	 * Private Interface
	 */
		private function swapChildren():void
		{
			if(_startChild && _cont.contains(_startChild)) _cont.removeChild(_startChild);
			
			if(_endChild) _cont.addChild(_endChild);
		}
	}
}