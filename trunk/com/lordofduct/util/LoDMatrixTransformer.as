/**
 * LoDMatrixTransformer - written by Dylan Engelman a.k.a LordOfDuct
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
 * 
 * 
 * 
 * 
 * 
 * 
 * All angles are defined in radians unless otherwise defined.
 * 
 * ex. getRotation( mat:Matrix ):Number returns in radians
 * getRotationDegrees( mat:Matrix ):Number returns in degrees
 */
package com.lordofduct.util
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class LoDMatrixTransformer
	{
		public function LoDMatrixTransformer()
		{
			Assertions.throwError("com.lorofduct.util::LoDMatrixTransformer - can not instantiate static member class.", Error);
		}
		
	/**
	 * Matrix Factory
	 */
		public static function createRotationMatrix( angle:Number ):Matrix
		{
			var mat:Matrix = new Matrix();
			mat.rotate(angle);
			return mat;
		}
		
		public static function createRotationMatrixDegrees( angle:Number ):Matrix
		{
			var mat:Matrix = new Matrix();
			mat.rotate( angle * LoDMath.DEG_TO_RAD );
			return mat;
		}
		
		public static function createTranslationMatrix( tx:Number, ty:Number ):Matrix
		{
			return new Matrix(1,0,0,1,tx,ty);
		}
		
		public static function createSkewMatrix( skewX:Number, skewY:Number ):Matrix
		{
			var mat:Matrix = new Matrix();
			setSkewX(mat, skewX);
			setSkewY(mat, skewY);
			return mat;
		}
		
		public static function createScaleMatrix( scaleX:Number, scaleY:Number ):Matrix
		{
			return new Matrix(scaleX, 0, 0, scaleY );
		}
		
	/**
	 * Open methods
	 */
		
		/**
		 * Get the X scale of a matrix
		 * 
		 * @param mat: a matrix to get the scaleX of
		 * 
		 * @return: the scaleX of m
		 */
		public static function getScaleX(mat:Matrix):Number
		{
			return Math.sqrt(mat.a*mat.a + mat.b*mat.b);
		}
		
		/**
		 * Set the X scale of a matrix
		 * 
		 * @param mat: a matrix to set the scaleX of
		 * 
		 * @param scaleX: the new scaleX
		 */
		public static function setScaleX(mat:Matrix, scaleX:Number):void
		{
			var scx:Number = getScaleX(mat);
			
			if (scx)
			{
				var ratio:Number = scaleX / scx;
				mat.a *= ratio;
				mat.b *= ratio;
			}
			else
			{
				//if tmp was 0, set scaleX from skewY
				var sky:Number = getSkewY(mat);
				mat.a = Math.cos(sky) * scaleX;
				mat.b = Math.sin(sky) * scaleX;
			}
		}
		
		/**
		 * Get the Y scale of a matrix
		 * 
		 * @param mat: a matrix to get the scaleY of
		 * 
		 * @return the scaleY of m
		 */
	   	public static function getScaleY(mat:Matrix):Number
		{
			return Math.sqrt(mat.c*mat.c + mat.d*mat.d);
		}
		
		/**
		 * Set the Y scale of a matrix
		 * 
		 * @param mat: a matrix to set the scaleX of
		 * 
		 * @param scaleY: the new scaleY
		 */
		public static function setScaleY(mat:Matrix, scaleY:Number):void
		{
			var scy:Number = getScaleY(mat);
			
			if (scy)
			{
				var ratio:Number = scaleY / scy;
				mat.c *= ratio;
				mat.d *= ratio;
			}
			else
			{
				//if tmp was 0, set scaleY from skewX
				var skx:Number = getSkewX(mat);
				mat.c = -Math.sin(skx) * scaleY;
				mat.d =  Math.cos(skx) * scaleY;
			}
		}
		
		public static function getSkewX(mat:Matrix):Number
		{
			return Math.atan2(-mat.c, mat.d);
		}
		
		public static function setSkewX(mat:Matrix, skewX:Number):void
		{
			var sky:Number = getScaleY(mat);
			mat.c = -sky * Math.sin(skewX);
			mat.d =  sky * Math.cos(skewX);
		}
		
		public static function getSkewY(mat:Matrix):Number
		{
			return Math.atan2(mat.b, mat.a);
		}
		
		public static function setSkewY(mat:Matrix, skewY:Number):void
		{
			var skx:Number = getScaleX(mat);
			mat.a = skx * Math.cos(skewY);
			mat.b = skx * Math.sin(skewY);
		}
		
		public static function getSkewXDegrees(mat:Matrix):Number
		{
			return Math.atan2(-mat.c, mat.d) * LoDMath.DEG_TO_RAD;
		}
		
	   	public static function setSkewXDegrees(mat:Matrix, skewX:Number):void
		{
			setSkewX(mat, skewX * LoDMath.DEG_TO_RAD);
		}
		
		public static function getSkewYDegrees(mat:Matrix):Number
		{
			return Math.atan2(mat.b, mat.a) * LoDMath.DEG_TO_RAD;
		}
		
		public static function setSkewYDegrees(mat:Matrix, skewY:Number):void
		{
			setSkewY(mat, skewY * LoDMath.DEG_TO_RAD);
		}
		
	   	public static function getRotation(mat:Matrix):Number
		{
			return getSkewY(mat);
		}
		
		public static function setRotation(mat:Matrix, rotation:Number):void
		{
			var or:Number = getRotation(mat);
			var oskx:Number = getSkewX(mat);
			setSkewX(mat, oskx + rotation-or);
			setSkewY(mat, rotation);
		}
		
		public static function getRotationDegrees(mat:Matrix):Number
		{
			return getRotation(mat) * LoDMath.DEG_TO_RAD;
		}
		
		public static function setRotationDegrees(mat:Matrix, rotation:Number):void
		{
			setRotation(mat, rotation * LoDMath.DEG_TO_RAD);
		}
		
		public static function rotateAroundInternalPoint(mat:Matrix, x:Number, y:Number, angle:Number):void
		{
			var point:Point = new Point(x, y);
			point = mat.transformPoint(point);
			mat.tx -= point.x;
			mat.ty -= point.y;
			mat.rotate(angle);
			mat.tx += point.x;
			mat.ty += point.y;
		}
		
		public static function rotateAroundExternalPoint(mat:Matrix, x:Number, y:Number, angle:Number):void
		{
			mat.tx -= x;
			mat.ty -= y;
			mat.rotate(angle);
			mat.tx += x;
			mat.ty += y;
		}
		
	    public static function matchInternalPointWithExternal(mat:Matrix, interPnt:Point, extPnt:Point):void
		{
			var pntT:Point = mat.transformPoint(interPnt);
			var dx:Number = extPnt.x - pntT.x;
			var dy:Number = extPnt.y - pntT.y;
			mat.tx += dx;
			mat.ty += dy;
		}
	}
}