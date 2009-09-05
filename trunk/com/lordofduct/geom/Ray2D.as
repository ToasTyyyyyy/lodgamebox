/**
 * Ray2D - written by Dylan Engelman a.k.a LordOfDuct
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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class Ray2D extends Point2D
	{
		private var _dx:Number = 0;
		private var _dy:Number = 0;
		private var _dirty:Boolean = true;
		
		public function Ray2D( px:Number=0, py:Number=0, dx:Number=0, dy:Number=0 )
		{
			super(px,py);
			_dx = dx;
			_dy = dy;
		}
		
		public function get dirX():Number { if(_dirty) clean(); return _dx; }
		public function set dirX(value:Number):void { _dx = value; _dirty = true; }
		
		public function get dirY():Number { if(_dirty) clean(); return _dy; }
		public function set dirY(value:Number):void { _dy = value; _dirty = true; }
		
		public function get position():Vector2 { return new Vector2( this.x, this.y ); }
		public function get direction():Vector2 { return new Vector2( this.dirX, this.dirY ); }
/**
 * Methods
 */
		/**
		 *ROTATE BY - rotates the vector n radians clockwise from the direction it is at
		 */
		public function rotateBy( angle:Number ):void
		{
			var ca:Number = Math.cos(angle);
			var sa:Number = Math.sin(angle);
			var rx:Number = this.dirX * ca - _dy * sa;
			_dy = _dx * sa + _dy * ca;
			_dx = rx;
		}
		static public function rotateBy( ray:Ray2D, angle:Number ):Ray2D
		{
			var ca:Number = Math.cos(angle);
			var sa:Number = Math.sin(angle);
			var rx:Number = ray.dirX * ca - ray.dirY * sa;
			
			return new Ray2D( ray.x, ray.y, rx, ray.dirX * sa + ray.dirY * ca);
		}
		
		/**
		 *ROTATE BY COS & SIN - access point of RotateBy where the user already has solved the cosine and sine
		 */
		public function rotateByCosSin( ca:Number, sa:Number ):void
		{
			var rx:Number = _dx * ca - _dy * sa;
			_dy = _dx * sa + _dy * ca;
			_dx = rx;
		}
		static public function rotateByCosSin( ray:Ray2D, ca:Number, sa:Number ):Ray2D
		{
			return new Ray2D( ray.x, ray.y, ray.dirX * ca - ray.dirY * sa, ray.dirX * sa + ray.dirY * ca);
		}
		
		/**
		 *ROTATE TO - returns a vector with respect to n degrees clockwise off the +x axis
		 */
		public function rotateTo( angle:Number ):void
		{
			_dx = Math.cos(angle);
			_dy = Math.sin(angle);
			_dirty = false;
		}
		static public function rotateTo( ray:Ray2D, angle:Number):Ray2D
		{
			return new Ray2D( ray.x, ray.y, Math.cos(angle), Math.sin(angle));
		}
		
		public function transformByMatrix( m:Matrix ):void
		{
			this.x += m.tx;
			this.y += m.ty;
			var ix:Number = _dx * m.a + _dy * m.c;
			var iy:Number = _dx * m.b + _dy * m.d;
			_dx = ix;
			_dy = iy;
		}
		
		static public function transformByMatrix( ray:Ray2D, m:Matrix ):Ray2D
		{
			var r2:Ray2D = new Ray2D();
			r2.x = ray.x + m.tx;
			r2.y = ray.y + m.ty;
			var ix:Number = ray.dirX * m.a + ray.dirY * m.c;
			var iy:Number = ray.dirX * m.b + ray.dirY * m.d;
			r2.dirX = ix;
			r2.dirY = iy;
			return r2;
		}
		
		public function rotateByMatrix( m:Matrix ):void
		{
			var ix:Number = _dx * m.a + _dy * m.c;
			var iy:Number = _dx * m.b + _dy * m.d;
			_dx = ix;
			_dy = iy;
		}
		
		static public function rotateByMatrix( ray:Ray2D, m:Matrix ):Ray2D
		{
			var r2:Ray2D = new Ray2D(ray.x, ray.y);
			var ix:Number = ray.dirX * m.a + ray.dirY * m.c;
			var iy:Number = ray.dirX * m.b + ray.dirY * m.d;
			r2.dirX = ix;
			r2.dirY = iy;
			return r2;
		}
/**
 *BASE METHODS
 *<p>the following is a series of methods for basic Vector cleanup</p>
 */
		private function clean():void
		{
			if(!_dx && !_dy)
			{
				_dirty = false;
				return;
			}
			
			var l:Number = Math.sqrt( _dx * _dx + _dy * _dy );
			_dx /= l;
			_dy /= l;
			_dirty = false;
		}
		
		override public function copy(obj:*):void
		{
			if(obj is Ray2D)
			{
				this.setTo( obj.x, obj.y );
				_dx = obj.dirX;
				_dy = obj.dirY;
			} else if ( obj is Point || obj is Point2D )
			{
				this.setTo( obj.x, obj.y );
			}
		}
		
		static public function copy(obj:Ray2D):Ray2D
		{
			if(obj is Ray2D) return new Ray2D( obj.x, obj.y, obj.dirX, obj.dirY );
			else return new Ray2D( obj.x, obj.y );
		}
		
		override public function clone():*
		{
			return new Ray2D( this.x, this.y, _dx, _dy );
		}
	}
}