package com.lordofduct.engines.animation
{
	import com.lordofduct.util.DeltaPulseTimer;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	
	public class LoDTweener
	{
		private static var _inst:LoDTweener;
		
		public static function get instance():LoDTweener
		{
			if (!_inst) _inst = SingletonEnforcer.gi(LoDTweener);
			
			return _inst;
		}
		
		public function LoDTweener()
		{
			SingletonEnforcer.assertSingle(LoDTweener);
			
			_timer = new DeltaPulseTimer(40);
			_frate = Math.round( 1000 / 40 );
			_timer.addEventListener(TimerEvent.TIMER, updateAll, false, 0, true );
		}
/**
 * Class Definition
 */
		private var _timer:DeltaPulseTimer;
		private var _frate:int;
		private var _members:Dictionary = new Dictionary();
	/**
	 * Properties
	 */
		/**
		 * How often a second should the Tweener globally update.
		 * Max value - 100
		 * Min value - 10
		 * 
		 * higher values mean better detail but more processing power
		 * lower values mean less detail with better efficiency
		 * 
		 * default value is 25. values from 25 to 40 are suggested.
		 */
		public function get frameRate():int { return _frate; }
		public function set frameRate( value:int ):void
		{
			var delay:int = Math.max( 10, Math.round( 1000 / value ) );
			_frate = Math.round(1000 / delay);
			_timer.pulseDelay = delay;
		}
		
	/**
	 * Methods
	 */
		public function registerTween( tween:ITween ):void
		{
			var obj:Object = (_members[tween.target]) ? _members[tween.target] : new Object();
			obj[tween.property] = tween;
			_members[tween.target] = obj;
			
			tween.update(_timer.deltaSinceLastTick());
		}
		
		public function tweenTo( obj:Object, func:Function, dur:Number, vars:Object, delay:Number=0 ):void
		{
			for (var prop:String in vars)
			{
				var tween:SimpleTween = new SimpleTween( obj, prop, func, dur, obj[prop], vars[prop], delay );
				registerTween( tween );
			}
		}
		
		public function tweenFrom( obj:Object, func:Function, dur:Number, vars:Object, delay:Number=0 ):void
		{
			for (var prop:String in vars)
			{
				var tween:SimpleTween = new SimpleTween( obj, prop, func, dur, vars[prop], obj[prop], delay );
				obj[prop] = vars[prop];
				registerTween( tween );
			}
		}
		
		public function getTweenFor( obj:Object, prop:String ):ITween
		{
			return (_members[obj]) ? _members[obj][prop] : null;
		}
		
		private function updateAll(e:TimerEvent):void
		{
			var dt:Number = _timer.dt;
			
			for each(var map:Object in _members)
			{
				for each(var tween:ITween in map)
				{
					if(tween.update(dt))
					{
						delete map[tween.property];
					}
				}
			}
		}
	}
}