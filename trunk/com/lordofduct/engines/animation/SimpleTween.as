package com.lordofduct.engines.animation
{
	import com.lordofduct.engines.animation.easing.Linear;
	import com.lordofduct.events.TweenerEvent;
	import com.lordofduct.util.LoDMath;
	
	public class SimpleTween extends EventDispatcher implements ITween
	{
		private var _targ:Object;
		private var _prop:String;
		private var _func:Function;
		private var _begin:Number;
		private var _finish:Number;
		private var _dur:Number;
		
		private var _pos:Number;
		private var _paused:Boolean = false;
		
		public function SimpleTween( targ:Object, prop:String, func:Function, dur:Number, begin:Number, finish:Number, startDelay:Number=0 )
		{
			if(!targ) return;
			
			_targ = targ;
			_prop = prop;
			_func = (func is Function) ? func : Linear.easeNone;
			_begin = begin;
			_finish = finish;
			_dur = dur;
			_delay = startDelay;
			
			LoDTweener.instance.registerTween( this );
		}
		
/**
 * Properties
 */
	/**
	 * ITween Interface
	 */
		public function get target():Object { return _targ; }
		public function get duration():Number { return _dur; }
		public function get passed():Number { return LoDMath.clamp( _pos - _delay, _dur ); }
		public function get position():Number { return this.passed / _dur; }
		public function get property():String { return _prop; }
		public function get delay():Number { return _delay; }
		
	/**
	 * SimpleTween Interface
	 */
		public function get funct():Function { return _func; }
		public function get startValue():Number { return _begin; }
		public function get endValue():Number { return _finish; }
/**
 * Methods
 */
	/**
	 * ITween Interface
	 */
		public function update(dt:Number):Boolean
		{
			if(_paused) return;
			
			var op:Number = _pos;
			_pos = LoDMath.clamp( _pos + dt, _dur );
			var t:Number = _pos - _delay;
			
			if( _pos < _delay ) return;
			else if ( op <= _delay && t > 0 )
			{
				this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_START, t ) );
			}
			
			_targ[_prop] = _funct( t, _begin, _finish - _begin, _dur );
			
			this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_UPDATE, this.position ) );
			
			if ( _pos >= _dur )
			{
				this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_COMPLETE, 1 ) );
				return true;
			} else {
				return false;
			}
		}
	/**
	 * SimpleTween Interface
	 */
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
			var ob:Number = _begin;
			_begin = _finish;
			_finish = _begin;
			
			_pos = _dur - _pos + _delay;
			this.update(0);
		}
	}
}