/**
 * DeltaFrameTimer - written by Dylan Engelman a.k.a LordOfDuct
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
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;

	final public class DeltaFrameTimer extends DeltaTimer
	{
		private var _frameDispatcher:DisplayObject;
		
		public function DeltaFrameTimer(frameDispatcher:DisplayObject=null, repeat:int=0 ):void
		{
			super(repeat);
			_frameDispatcher = (frameDispatcher) ? frameDispatcher : new Shape();
		}
		
		/**
		 * Start the timer, resets the timer before 
		 * restarting in case start has already been 
		 * called before.
		 */
		override public function start(repeat:int=-1):void
		{
			super.start(repeat);
			
			_frameDispatcher.addEventListener(Event.ENTER_FRAME, updateByFrame, false, 0, true);
		}
		
		/**
		 * Pauses the timer
		 */
		override public function pause():void
		{
			super.pause();
			
			_frameDispatcher.removeEventListener(Event.ENTER_FRAME, updateByFrame);
		}
		
		/**
		 * resumes the timer if paused.
		 */
		override public function resume():void
		{
			super.resume();
			
			if(!this.paused) _frameDispatcher.addEventListener(Event.ENTER_FRAME, updateByFrame, false, 0, true);
		}
		
		/**
		 * resets the timer to 0 and stops it
		 */
		override public function reset():void
		{
			super.reset();
			
			_frameDispatcher.removeEventListener(Event.ENTER_FRAME, updateByFrame);
		}
		
		override protected function repeatCountDone():void
		{
			super.repeatCountDone();
			
			_frameDispatcher.removeEventListener(Event.ENTER_FRAME, updateByFrame);
		}
		
/**
 * Private Interface
 */
		/**
		 * function that updates the dt value for use every frame
		 */
		private function updateByFrame(e:Event):void
		{
			this.update();
			
			this.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
	}
}