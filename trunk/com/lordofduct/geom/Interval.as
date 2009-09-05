/**
 * Interval - written by Dylan Engelman a.k.a LordOfDuct
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
package com.lordofduct.geom
{
	import com.lordofduct.util.IClonable;
	
	import flash.geom.Point;
	
	public class Interval implements IClonable
	{
		private var _min:Number;
		private var _max:Number;
		private var _axis:Vector2;
		
		public function Interval(low:Number=0, high:Number=0, axis:Vector2=null)
		{
			_min = low;
			_max = high;
			_axis = axis;
			resortValues();
		}
/**
 * Properties
 */
		public function get min():Number {return _min;}
		public function set min( value:Number ):void { _min = value; resortValues(); }
		
		public function get max():Number {return _max;}
		public function set max( value:Number ):void { _max = value; resortValues(); }
		
		public function get axis():Vector2 { return _axis; }
		public function set axis(value:Vector2):void { _axis = value; }
		
		public function get intervalLength():Number
		{
			return Math.abs(_max - _min);
		}
		
/**
 * Methods
 */
		public function concat( interval:Interval ):void
		{
			_min = Math.min( this.min, interval.min );
			_max = Math.max( this.max, interval.max );
			resortValues();
		}
		
		public function intervalIntersection( interval:Interval ):Interval
		{
			if (this.max < interval.min) return null;
			if ( this.min > interval.max) return null;
			
			return new Interval( Math.max( this.min, interval.min ), Math.min( this.max, interval.max ), (_axis) ? _axis.clone() : null );
		}
		
		public function midPointBetween( interval:Interval ):Number
		{
			var arr:Array = [ this.min, this.max, interval.min, interval.max ];
			arr.sort(Array.NUMERIC);
			return (arr[2] + arr[1]) / 2;
		}
		
		public function distanceBetween( interval:Interval ):Number
		{
			if (this.max > interval.min ) return 0;
			if (this.min < interval.max ) return 0;
			
			return Math.abs( this.max - interval.min );
		}
		
	/**
	 * General Use
	 */
		private function resortValues():void
		{
			if(_min > _max)
			{
				var ty:Number = _min;
				_min = _max;
				_max = ty;
			}
		}
		
		public function setTo( low:Number=0, high:Number=0 ):void
		{
			_min = low;
			_max = high;
			resortValues();
		}
		
		public function copy( obj:* ):void
		{
			if(obj is Interval) this.setTo( obj.min, obj.max );
			if(obj is Point2D || obj is Point) this.setTo(obj.x, obj.y);
		}
		
		static public function copy( obj:* ):Interval
		{
			if(obj is Interval) return new Interval(obj.min, obj.max);
			if(obj is Point2D || obj is Point) return new Interval(obj.x, obj.y);
			else return null;
		}
		
		public function clone():*
		{
			return new Interval( _min, _max );
		}
		
		public function convertToASPoint():Point
		{
			return new Point( this.min, this.max );
		}
	}
}