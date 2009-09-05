/**
 * Point2D - written by Dylan Engelman a.k.a LordOfDuct
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
	
	public class Point2D implements IClonable
	{
		private var _x:Number;
		private var _y:Number;
		
		public function Point2D( i:Number=0, j:Number=0 )
		{
			_x = i;
			_y = j;
		}
		
		public function get x():Number { return _x; }
		public function set x( value:Number ):void { _x = value; }
		
		public function get y():Number { return _y; }
		public function set y( value:Number ):void { _y = value; }
		
		public function setTo( i:Number=0, j:Number=0 ):void
		{
			this.x = i;
			this.y = j;
		}
		
		public function copy( obj:* ):void
		{
			if(obj is Point2D || obj is Point) this.setTo(obj.x, obj.y);
		}
		
		static public function copy( obj:* ):Point2D
		{
			if(obj is Point2D || obj is Point) return new Point2D(obj.x, obj.y);
			else return null;
		}
		
		public function clone():*
		{
			return new Point2D( this.x, this.y );
		}
		
		public function convertToASPoint():Point
		{
			return new Point( this.x, this.y );
		}
	}
}