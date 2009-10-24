package com.lordofduct.engines.animation.transitions
{
	import com.lordofduct.engines.animation.IChildTransition;
	import com.lordofduct.engines.animation.easing.Linear;
	import com.lordofduct.events.TweenerEvent;
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDDisplayObjUtils;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;

	public class CrossFadeTransition extends EventDispatcher implements IChildTransition
	{
		private var _startChild:DisplayObject;
		private var _endChild:DisplayObject;
		private var _cont:DisplayObjectContainer;
		
		private var _funct:Function;
		
		private var _delay:Number;
		private var _dur:Number;
		private var _pos:Number;
		
		private var _paused:Boolean = false;
		
		public function CrossFadeTransition( cont:DisplayObjectContainer, start:DisplayObject, end:DisplayObject, func:Function, dur:Number=0, startDelay:Number=0 )
		{
			super();
			
			Assertions.notNil( cont, "com.lordofduct.engines.animation.transitions:: IChildTransition - relatedContainer must be non-null." );
			Assertions.notNil( func, "com.lordofduct.engines.animation.transitions:: IChildTransition - func must be non-null." );
			_startChild = start;
			_endChild = end;
			_cont = cont;
			
			_funct = func;
			
			_dur = dur;
			_delay = Math.max(0, startDelay);
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
			
			//check start
			if( _pos < _delay ) return false;
			else if ( op <= _delay && t > 0 )
			{
				startTransition();
				this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_START, this.target, t ) );
			}
			
			//update
			var a:Number = _funct( t, 0, 1, _dur );
			if(_startBmp) _startBmp.alpha = 1 - a;
			if(_endBmp) _endBmp.alpha = a;
			
			this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_UPDATE, this.target, this.position ) );
			
			//check complete
			if ( _pos - _delay >= _dur )
			{
				this.finishTransition();
				this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_COMPLETE, this.target, 1 ) );
				return true;
			} else {
				return false;
			}
		}
		
		public function pause():void
		{
			if(_paused) return;
			
			_paused = true;
			this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_PAUSE, this.target, this.position ) );
		}
		
		public function resume():void
		{
			if(!_paused) return;
			
			_paused = false;
			this.dispatchEvent( new TweenerEvent( TweenerEvent.TWEEN_RESUME, this.target, this.position ) );
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
			if(_startBmp)
			{
				if(_cont && _cont.contains(_startBmp)) _cont.removeChild(_startBmp);
				
				_startBmp.bitmapData.dispose();
				_startBmp = null;
			}
			
			if(_endBmp)
			{
				if(_cont && _cont.contains(_endBmp)) _cont.removeChild(_endBmp);
				
				_endBmp.bitmapData.dispose();
				_endBmp = null;
			}
			
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
		private var _startBmp:Bitmap;
		private var _endBmp:Bitmap;
		
		private function startTransition():void
		{
			if(_startChild)
			{
				_startBmp = LoDDisplayObjUtils.drawDisplayObjectAsIs( _startChild );
				
				if(_cont.contains( _startChild)) _cont.removeChild(_startChild);
				
				_startBmp.x = _startChild.x;
				_startBmp.y = _startChild.y;
				_startBmp.alpha = 1;
				_cont.addChild( _startBmp );
			}
			
			if(_endChild)
			{
				_endBmp = LoDDisplayObjUtils.drawDisplayObjectAsIs( _endChild );
				
				if(_cont.contains( _endChild)) _cont.removeChild(_endChild);
				
				_endBmp.x = _endChild.x;
				_endBmp.y = _endChild.y;
				_endBmp.alpha = 0;
				_cont.addChild( _endBmp );
			}
		}
		
		private function finishTransition():void
		{
			if(_startBmp)
			{
				if(_cont.contains(_startBmp)) _cont.removeChild(_startBmp);
				
				_startBmp.bitmapData.dispose();
				_startBmp = null;
			}
			
			if(_endBmp)
			{
				if(_cont.contains(_endBmp)) _cont.removeChild(_endBmp);
				
				_endBmp.bitmapData.dispose();
				_endBmp = null;
			}
			
			if(_startChild && _cont.contains(_startChild)) _cont.removeChild(_startChild);
			
			if(_endChild) _cont.addChild(_endChild);
		}
		
	}
}