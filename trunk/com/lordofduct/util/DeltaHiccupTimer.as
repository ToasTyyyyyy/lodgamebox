/**
 * DeltaPulseTimer - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * Copyright (c) 2009 Dylan Engelman
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, 
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject to the following 
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies 
 * or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * 
 * In other words, no guarantees are made that it will work as expected nor that I (Dylan Engelman) 
 * have to repair or give any assistance to you the user when you have troubles.
 * 
 */
package com.lordofduct.util
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class DeltaHiccupTimer extends DeltaTimer
	{
		private var _timer:Timer;
		
		private var _delay:int;
		private var _hiccup:int;
		
		public function DeltaHiccupTimer( delay:int=1000, repeat:int=0  )
		{
			super(repeat);
			_delay = delay;
			_timer = new Timer(_delay);
		}
		
		public function get pulseDelay():int { return _delay; }
		public function set pulseDelay( value:int ):void { _delay = value; _timer.delay = _delay; }
/**
 * Overrides
 */
		/**
		 * Start the timer, resets the timer before 
		 * restarting in case start has already been 
		 * called before.
		 */
		override public function start(repeat:int=-1):void
		{
			super.start(repeat);
			
			_timer.addEventListener(TimerEvent.TIMER, updateByPulse, false, 0, true );
			_timer.reset();
			_timer.start();
			_hiccup = 0;
		}
		
		/**
		 * Pauses the timer
		 */
		override public function pause():void
		{
			super.pause();
			
			_timer.removeEventListener(TimerEvent.TIMER, updateByPulse );
			_hiccup = this.deltaSinceLastTick();
			_timer.stop();
		}
		
		/**
		 * resumes the timer if paused.
		 */
		override public function resume():void
		{
			var bool:Boolean = this.paused;
			
			super.resume();
			
			if(bool)
			{
				var d:int = _delay - (_hiccup % _delay);
				if(d <= 0)
				{
					this.resumeWithHiccup(null);
					return;
				}
				_timer.delay = d;
				_timer.addEventListener(TimerEvent.TIMER, resumeWithHiccup, false, 0, true );
				_timer.start();
			}
		}
		
		/**
		 * resets the timer to 0 and stops it
		 */
		override public function reset():void
		{
			super.reset();
			
			_timer.removeEventListener(TimerEvent.TIMER, updateByPulse );
			_timer.stop();
			_timer.reset();
		}
		
		override protected function repeatCountDone():void
		{
			super.repeatCountDone();
			
			_timer.removeEventListener(TimerEvent.TIMER, updateByPulse );
			_timer.stop();
		}
		
/**
 * Private Interface
 */
		/**
		 * function that updates the dt value for use every Timer pulse
		 */
		private function updateByPulse(e:TimerEvent):void
		{
			this.update();
		}
		
		private function resumeWithHiccup(e:TimerEvent):void
		{
			_timer.removeEventListener(TimerEvent.TIMER, resumeWithHiccup );
			_timer.stop();
			_timer.delay = _delay;
			_timer.addEventListener(TimerEvent.TIMER, updateByPulse, false, 0, true );
			_hiccup = 0;
			this.updateByPulse(e);
			_timer.start();
		}
	}
}