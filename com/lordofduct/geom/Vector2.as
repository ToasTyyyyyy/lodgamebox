/**
 * Vector2 - written by Dylan Engelman a.k.a LordOfDuct
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
	import com.lordofduct.util.LoDMath;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class Vector2 extends Point2D
	{
		private var _dirty:Boolean = true;
		private var _length:Number;
		
		public function Vector2( i:Number=0, j:Number=0 )
		{
			super( i, j );
		}
		
/**
 *STATIC CONSTANTS
 */
 		/**
		 *+y down specific directions, used by flash
		 */
		static public function get Down():Vector2 { return new Vector2(0,1); }
		static public function get Left():Vector2 { return new Vector2(-1,0); }
		static public function get Right():Vector2 { return new Vector2(1,0); }
		static public function get Up():Vector2 { return new Vector2(0,-1); }
		
		static public function get One():Vector2 { return new Vector2(1,1); }
		static public function get UnitX():Vector2 { return new Vector2(1,0); }
		static public function get UnitY():Vector2 { return new Vector2(0,1); }
		static public function get Zero():Vector2 { return new Vector2(0,0); }
		
/**
 *ACCESSOR METHODS
 *<p>Accessor methods to keep the internal properties protected</p>
 */
		
		public function get i():Number {return this.x;}
		public function set i( value:Number ):void { this.x = value; }
		
		public function get j():Number {return this.y;}
		public function set j( value:Number ):void { this.y = value; }
		
		public function get dirty():Boolean {return _dirty;}
		
		public function get length():Number
		{
			if(_dirty) {
				_length = Math.sqrt(this.x * this.x + this.y * this.y);
				_dirty = false;
			}
			return _length;
		}
		public function set length( len:Number ):void
		{
			var l:Number = this.length;
			if(!l) return;
			
			this.x /= l / len;
			this.y /= l / len;
			
			_length = Math.abs(len);
			_dirty = false;
		}
		
		public function get lengthSquared():Number {return this.x * this.x + this.y * this.y;}
		
		override public function set x(x:Number):void { super.x = x; _dirty = true; }
		override public function set y(y:Number):void { super.y = y; _dirty = true; }
		
/**
 *VECTOR ARITHMETIC
 *<p>The following is a series of basic Math methods for Vectors. If performed directly to the 
 * Vector2, then the actual vector itself is updated. Utilize static methods to get new Vectors.</p>
 */
		
		/**
		 *NEGATE - returns a Vector in the opposite direction
		 */
		public function negate():void
		{
			this.x = -this.x;
			this.y = -this.y;
		}
		static public function negate( v:* ):Vector2
		{
			return new Vector2(-v.x, -v.y);
		}
		
		/**
		 *NORMALIZE - returns a Vector of magnitude 1
		 */
		public function normalize():void
		{
			var l:Number = this.length;
			if(!l) return;
			
			this.x /= l;
			this.y /= l;
			_length = 1;
			_dirty = false;
		}
		static public function normalize( v:* ):Vector2
		{
			var l:Number = v.length;
			if(!l) l = 1;
			return new Vector2(v.x/l, v.y/l);
		}
		
		/**
		 *DOT - returns a Number equal to the dot product of 2 vectors
		 */
		public function dot( v:* ):Number
		{
			return this.x * v.x + this.y * v.y;
		}
		static public function dot( v1:*, v2:*):Number
		{
			return v1.x * v2.x + v1.y * v2.y;
		}
		
		/**
		 *add - returns the sum of to vectors
		 */
		public function add( v:* ):void
		{
			this.x += v.x;
			this.y += v.y;
			//TODO - depricated dirty set
			_dirty = true;
		}
		static public function add( v1:*, v2:* ):Vector2
		{
			return new Vector2(v1.x + v2.x, v1.y + v2.y);
		}
		
		/**
		 *subtract - returns the difference of two vectors
		 *v2 subtracts from v1/this
		 */
		public function subtract( v:* ):void
		{
			this.x -= v.x;
			this.y -= v.y;
			
			//TODO - depricated dirty set
			_dirty = true;
		}
		static public function subtract( v1:*, v2:*):Vector2
		{
			return new Vector2(v1.x - v2.x, v1.y - v2.y);
		}
		
		/**
		 *MULTIPLY - returns a vector scaled by some number f
		 */
		public function multiply( f:Number ):void
		{
			this.x *= f;
			this.y *= f;
			//TODO - depricated dirty set
			_dirty = true;
		}
		static public function multiply( v:*, f:Number):Vector2
		{
			return new Vector2(v.x * f, v.y * f);
		}
		
		/**
		 *DIVIDE - returns a vectors reduced by some number f
		 */
		public function divide( d:Number ):void
		{
			this.x /= d;
			this.y /= d;
			//TODO - depricated dirty set
			_dirty = true;
		}
		static public function divide( v:*, d:Number):Vector2
		{
			 return new Vector2(v.x / d, v.y / d);
		}
		
/**
 *VECTOR MATH FUNCTIONS
 *<p>more advanced vector math</p>
 */
		public function lerp(v:*, weight:Number):void
		{
			var ix:Number = (v.x - this.x) * weight + this.x;
			var iy:Number = (v.y - this.y) * weight + this.y;
			
			this.x = ix;
			this.y = iy;
		}
		
		static public function lerp(v1:*, v2:*, weight:Number):Vector2
		{
			var nV:Vector2 = Vector2.subtract(v2, v1);
			nV.multiply(weight);
			nV.add(v1);
			return nV;
		}
		
		public function lerpRotation(v:*, weight:Number):void
		{
			var a1:Number = this.angle();
			var a2:Number = Vector2.angle(v);
			var chng:Number = LoDMath.nearestAngleBetween( a1, a2 );
			chng *= weight;
			
			this.rotateBy(chng);
		}
		
		static public function lerpRotation(v1:*, v2:*, weight:Number):Vector2
		{
			var a1:Number = Vector2.angle(v1);
			var a2:Number = Vector2.angle(v2);
			var chng:Number = LoDMath.nearestAngleBetween( a1, a2 );
			chng *= weight;
			
			return Vector2.rotateBy(v1, chng);
		}
		
		static public function distance(v1:*, v2:*):Number
		{
			var v:Vector2 = Vector2.subtract(v1, v2);
			return v.length;
		}
		
		static public function distanceSquared(v1:*, v2:*):Number
		{
			var v:Vector2 = Vector2.subtract(v1, v2);
			return v.lengthSquared;
		}
		
		static public function simpleAngle( v:* ):Number
		{
			return Math.atan( v.y / v.x );
		}
		
		public function perp():void
		{
			this.setTo( -this.y, this.x );
		}
		
		static public function perp(v:*):Vector2
		{
			return new Vector2(-v.y, v.x);
		}
		
		/**
		 *ORTHOGONAL - bad name for a vector rotated 90 degrees clockwise
		 * 
		 * depricated, use perp() instead.
		 */
		static public function orth(v:*):Vector2
		{
			return new Vector2(-v.y, v.x);
		}
		
		/**
		 *NORMAL - returns a unit vector 90 degrees clockwise off the input vector
		 */
		public function normal():void
		{
			this.perp();
			this.length = 1;
		}
		
		static public function normal(v:*):Vector2
		{
			var l:Number = (v is Vector2) ? v.length : Math.sqrt(v.x * v.x + v.y * v.y);
			if(!l) l = 1;
			
			return new Vector2(-v.y / l, v.x / l);
		}
		
/**
 *VECTOR TRIG
 *<p>The following is a series of Vector trig methods to make life easier. If performed directly to the 
 * Vector2, then the actual vector itself is updated. Utilize static methods to get new Vectors.</p>
 */
		
		/**
		 *ANGLE - returns a number equal the angle of the vector clockwise off the +x axis
		 */
		public function angle():Number
		{
			return Math.atan2(this.y,this.x);
		}
		static public function angle( v:* ):Number
		{
			return Math.atan2(v.y, v.x);
		}
		
		/**
		 *ANGLE BETWEEN - returns a number equal the angle between two vectors
		 */
		public function angleBetween( v:* ):Number
		{
			return Math.acos( this.dot(v) / (this.length * v.length));
		}
		static public function angleBetween( v1:*, v2:* ):Number
		{
			return Math.acos( Vector2.dot(v1, v2) / (v1.length * v2.length));
		}
		
		/**
		 *REFLECT - returns a vector reflected over some obtuse axis
		 */
		public function reflect( normal:* ):void
		{
			var dp:Number = 2 * this.dot(normal);
			this.x -= normal.x * dp;
			this.y -= normal.y * dp;
			
			//TODO - depricated dirty set
			_dirty = true;
		}
		static public function reflect(v:*, normal:* ):Vector2
		{
			var dp:Number = 2 * Vector2.dot(v, normal);
			
			return new Vector2(v.x - normal.x * dp, v.y - normal.y * dp);
		}
		
		/**
		 *ROTATE BY - rotates the vector n radians clockwise from the direction it is at
		 */
		public function rotateBy( angle:Number ):void
		{
			var ca:Number = Math.cos(angle);
			var sa:Number = Math.sin(angle);
			var rx:Number = this.x * ca - this.y * sa;
			this.y = this.x * sa + this.y * ca;
			this.x = rx;
		}
		static public function rotateBy( v:*, angle:Number ):Vector2
		{
			var ca:Number = Math.cos(angle);
			var sa:Number = Math.sin(angle);
			var rx:Number = v.x * ca - v.y * sa;
			
			return new Vector2( rx, v.x * sa + v.y * ca);
		}
		
		/**
		 *ROTATE BY COS & SIN - access point of RotateBy where the user already has solved the cosine and sine
		 */
		public function rotateByCosSin( ca:Number, sa:Number ):void
		{
			var rx:Number = this.x * ca - this.y * sa;
			this.y = this.x * sa + this.y * ca;
			this.x = rx;
		}
		static public function rotateByCosSin( v:*, ca:Number, sa:Number ):Vector2
		{
			return new Vector2( v.x * ca - v.y * sa, v.x * sa + v.y * ca);
		}
		
		/**
		 *ROTATE TO - returns a vector with respect to n degrees clockwise off the +x axis
		 */
		public function rotateTo( angle:Number ):void
		{
			var l:Number = this.length;
			this.x = Math.cos(angle) * l;
			this.y = Math.sin(angle) * l;
		}
		static public function rotateTo( v:*, angle:Number):Vector2
		{
			var l:Number = v.length;
			return new Vector2( Math.cos(angle) * l, Math.sin(angle) * l);
		}
		
		/**
		 * TRANSFORM BY - transform a vector by a matrix as a static ray from 0,0
		 */
		public function transformByMatrix( m:Matrix ):void
		{
			var ix:Number = this.x * m.a + this.y * m.c + m.tx;
			var iy:Number = this.x * m.b + this.y * m.d + m.ty;
			this.setTo( ix, iy );
		}
		
		static public function transformByMatrix( v:*, m:Matrix ):Vector2
		{
			var ix:Number = v.x * m.a + v.y * m.c + m.tx;
			var iy:Number = v.x * m.b + v.y * m.d + m.ty;
			return new Vector2(ix, iy);
		}
		
		/**
		 * ROTATE BY - transform a vector by a matrix as a free-floating entity
		 * 
		 * basically the matrix's tx and ty properties are ignored allowing for 
		 * free-floating vectors to be transformed.
		 */
		public function rotateByMatrix( m:Matrix ):void
		{
			var ix:Number = this.x * m.a + this.y * m.c;
			var iy:Number = this.x * m.b + this.y * m.d;
			this.setTo( ix, iy );
		}
		
		static public function rotateByMatrix( v:*, m:Matrix ):Vector2
		{
			var ix:Number = v.x * m.a + v.y * m.c;
			var iy:Number = v.x * m.b + v.y * m.d;
			return new Vector2(ix, iy);
		}
		
/**
 *BASE METHODS
 *<p>the following is a series of methods for basic Vector cleanup</p>
 */
		public function equals( v:* ):Boolean
		{
			return (v.x == this.x && v.y == this.y);
		}
		static public function equals( v1:*, v2:* ):Boolean
		{
			return (v1.x == v2.x && v1.y == v2.y);
		}
		
		public function fuzzyEquals( v:*, epsilon:Number=0.0001 ):Boolean
		{
			return (LoDMath.fuzzyEqual(v.x, this.x, epsilon) && LoDMath.fuzzyEqual(v.y, this.y, epsilon))
		}
		static public function fuzzyEquals( v1:*, v2:*, epsilon:Number=0.0001 ):Boolean
		{
			return (LoDMath.fuzzyEqual(v1.x, v2.x, epsilon) && LoDMath.fuzzyEqual(v1.y, v2.y, epsilon))
		}
		
	/**
	 * IClonable Interface
	 */
		static public function copy(obj:*):Vector2
		{
			if(obj is Point2D || obj is Point) return new Vector2(obj.x, obj.y);
			else return null;
		}
		
		/**
		 *CLONE - returns a vector equal to the this
		 */
		override public function clone():*
		{
			return new Vector2( this.x, this.y );
		}
		
		/**
		 *TO STRING - returns a String representation of the vector
		 *traces: [Vector2 i: iValue j: jValue length: lengthValue]
		 */
		public function toString(): String
		{
			var rx:String = this.x.toFixed( 4 );
			var ry:String = this.y.toFixed( 4 );
			return '[Vector2 i: ' + rx + ' j: ' + ry + ' length: ' + this.length + ']';
		}
	}
}