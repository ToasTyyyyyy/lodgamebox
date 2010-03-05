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
 * 
 * NOTE - when dealing with scale very often do you get to select if 'respect' is given to the local space.
 * 
 * What this means is the scale set relative to the matrix, or relative to the world.
 * 
 * If you break apart a matrix as two axis vectors and a position you get:
 * 
 * x axis - <a,b>
 * y axis - <c,d>
 * position (tx,ty)
 * 
 * if respect is true then the scale is done on the axis:
 * 
 * scaling x == scale * <a,b>
 * 
 * if respect is false the the scale is done to the x values:
 * 
 * scaling x no respect == scale * <a,c>
 * 
 * what results is when given respect the matrix will scale in the direction it is rotated. When not given the matrix 
 * is scaled explicitly in the parents rotated direction.
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
		 * @param respect - if true scale is with respect to the local space
		 * 
		 * @return: the scaleX of m
		 */
		public static function getScaleX(mat:Matrix, respect:Boolean=true):Number
		{
			return (respect) ? Math.sqrt(mat.a*mat.a + mat.b*mat.b) : Math.sqrt(mat.a*mat.a + mat.c*mat.c);
		}
		
		/**
		 * Set the X scale of a matrix
		 * 
		 * @param mat: a matrix to set the scaleX of
		 * 
		 * @param scaleX: the new scaleX
		 * 
		 * @param respect - if true scale is with respect to the local space
		 */
		public static function setScaleX(mat:Matrix, scaleX:Number, respect:Boolean=true):void
		{
			var scx:Number = getScaleX(mat,respect);
			
			if (scx)
			{
				var ratio:Number = scaleX / scx;
				
				mat.a *= ratio;
				if(respect)
					mat.b *= ratio;
				else 
					mat.c *= ratio;
			}
			else
			{
				//if tmp was 0, set scaleX from skewY
				var sky:Number = getSkewY(mat);
				mat.a = Math.cos(sky) * scaleX;
				if(respect)
					mat.b = Math.sin(sky) * scaleX;
				else
					mat.c = Math.sin(sky) * scaleX;
			}
		}
		
		/**
		 * Get the Y scale of a matrix
		 * 
		 * @param mat: a matrix to get the scaleY of
		 * 
		 * @param respect - if true scale is with respect to the local space
		 * 
		 * @return the scaleY of m
		 */
	   	public static function getScaleY(mat:Matrix, respect:Boolean=true):Number
		{
			return (respect) ? Math.sqrt(mat.c*mat.c + mat.d*mat.d) : Math.sqrt(mat.d*mat.d + mat.b*mat.b);
		}
		
		/**
		 * Set the Y scale of a matrix
		 * 
		 * @param mat: a matrix to set the scaleY of
		 * 
		 * @param scaleY: the new scaleY
		 * 
		 * @param respect - if true scale is with respect to the local space
		 */
		public static function setScaleY(mat:Matrix, scaleY:Number, respect:Boolean=true):void
		{
			var scy:Number = getScaleY(mat,respect);
			
			if (scy)
			{
				var ratio:Number = scaleY / scy;
				
				if(respect)
					mat.c *= ratio;
				else
					mat.b *= ratio;
				
				mat.d *= ratio;
			}
			else
			{
				//if tmp was 0, set scaleY from skewX
				var skx:Number = getSkewX(mat);
				if(respect)
					mat.c = -Math.sin(skx) * scaleY;
				else
					mat.b = -Math.sin(skx) * scaleY;
				
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
		
		/**
		 * rotate a matrix TO a value around a given internal point
		 * 
		 * @param mat - the Matrix to rotate
		 * @param x - the x position of the point
		 * @param y - the y position of the point
		 * @param angle - the angle in radians to rotate TO
		 */
		public static function rotateToAroundInternalPoint(mat:Matrix, x:Number, y:Number, angle:Number):void
		{
			var point:Point = new Point(x, y);
			point = mat.transformPoint(point);
			mat.tx -= point.x;
			mat.ty -= point.y;
			setRotation(mat,angle);
			mat.tx += point.x;
			mat.ty += point.y;
		}
		
		/**
		 * rotate a matrix TO a value around a given external point
		 * 
		 * @param mat - the Matrix to rotate
		 * @param x - the x position of the point
		 * @param y - the y position of the point
		 * @param angle - the angle in radians to rotate TO
		 */
		public static function rotateToAroundExternalPoint(mat:Matrix, x:Number, y:Number, angle:Number):void
		{
			mat.tx -= x;
			mat.ty -= y;
			setRotation(mat,angle);
			mat.tx += x;
			mat.ty += y;
		}
		
		/**
		 * rotate a matrix TO a value around a given internal point
		 * 
		 * @param mat - the Matrix to rotate
		 * @param x - the x position of the point
		 * @param y - the y position of the point
		 * @param angle - the angle in radians to rotate BY
		 */
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
		
		/**
		 * rotate a matrix TO a value around a given external point
		 * 
		 * @param mat - the Matrix to rotate
		 * @param x - the x position of the point
		 * @param y - the y position of the point
		 * @param angle - the angle in radians to rotate BY
		 */
		public static function rotateAroundExternalPoint(mat:Matrix, x:Number, y:Number, angle:Number):void
		{
			mat.tx -= x;
			mat.ty -= y;
			mat.rotate(angle);
			mat.tx += x;
			mat.ty += y;
		}
		
		/**
		 * Scale a matrix TO a value around a given internal point
		 * 
		 * @param mat - matrix to scale
		 * @param x - x point
		 * @param y - y point
		 * @param sx - x scale to set
		 * @param sy - y scale to set
		 * @param respect - if true scale is with respect to the local space
		 */
		public static function scaleToAroundInternalPoint(mat:Matrix, x:Number, y:Number, sx:Number, sy:Number, respect:Boolean = true):void
		{
			var intPnt:Point = new Point(x,y);
			var extPnt:Point = mat.transformPoint( intPnt );
			
			setScaleX(mat,sx,respect);
			setScaleY(mat,sy,respect);
			
			matchInternalPointWithExternal( mat, intPnt, extPnt );
		}
		
		/**
		 * Scale a matrix TO a value around a given external point
		 * 
		 * @param mat - matrix to scale
		 * @param x - x point
		 * @param y - y point
		 * @param sx - x scale to set
		 * @param sy - y scale to set
		 * @param respect - if true scale is with respect to the local space
		 */
		public static function scaleToAroundExternalPoint(mat:Matrix, x:Number, y:Number, sx:Number, sy:Number, respect:Boolean = true):void
		{
			var m2:Matrix = mat.clone();
			m2.invert();
			var extPnt:Point = new Point(x,y);
			var intPnt:Point = m2.transformPoint( extPnt );
			
			setScaleX(mat,sx,respect);
			setScaleY(mat,sy,respect);
			
			matchInternalPointWithExternal( mat, intPnt, extPnt );
		}
		
		/**
		 * Scale a matrix around a given internal point 
		 * 
		 * @param mat - matrix to scale 
		 * @param x - x point 
		 * @param y - y point 
		 * @param sx - x scale to set 
		 * @param sy - y scale to set 
		 * @param respect - if true scale is with respect to the local space 
		 * 
		 */
		public static function scaleAroundInternalPoint(mat:Matrix, x:Number, y:Number, sx:Number, sy:Number, respect:Boolean = true):void
		{
			var intPnt:Point = new Point(x,y);
			var extPnt:Point = mat.transformPoint( intPnt );
			
			if(respect)
			{
				mat.a *= sx;
				mat.b *= sx;
				mat.c *= sy;
				mat.d *= sy;
			} else {
				mat.scale(sx,sy);
			}
			
			matchInternalPointWithExternal( mat, intPnt, extPnt );
		}
		
		/**
		 * Scale a matrix around a given external point
		 * 
		 * @param mat - matrix to scale
		 * @param x - x point
		 * @param y - y point
		 * @param sx - x scale to set
		 * @param sy - y scale to set
		 * @param respect - if true scale is with respect to the local space 
		 * 
		 */
		public static function scaleAroundExternalPoint(mat:Matrix, x:Number, y:Number, sx:Number, sy:Number, respect:Boolean = true):void
		{
			var m2:Matrix = mat.clone();
			m2.invert();
			var extPnt:Point = new Point(x,y);
			var intPnt:Point = m2.transformPoint( extPnt );
			
			if(respect)
			{
				mat.a *= sx;
				mat.b *= sx;
				mat.c *= sy;
				mat.d *= sy;
			} else {
				mat.scale(sx,sy);
			}
			
			matchInternalPointWithExternal( mat, intPnt, extPnt );
		}
		
		public static function matchInternalPointWithExternal(mat:Matrix, interPnt:Point, extPnt:Point):void
		{
			var pntT:Point = mat.transformPoint(interPnt);
			var dx:Number = extPnt.x - pntT.x;
			var dy:Number = extPnt.y - pntT.y;
			mat.tx += dx;
			mat.ty += dy;
		}
		
		/**
		 * Linearly interpolate between 2 Matrices.
		 * 
		 * @parm m1 - Start Matrix
		 * @param m2 - End Matrix
		 * @param weight - lerp value from 0->1
		 * @param ease - if you want to use an easing function for interpolation, apply it here.
		 * 
		 * Caution, this is a 'linear interpolation'. A matrix which holds rotations may not look the way expected because 
		 * rotations are not linear values. When lerping rotations you'll get a result that looks a bit like skewing and 
		 * scaling during the lerp.
		 * 
		 * Use roterpMatrix method if you want to interpolate rotation.
		 */
		public static function lerpMatrix( m1:Matrix, m2:Matrix, weight:Number, ease:Function=null ):Matrix
		{
			var useEase:Boolean = ease is Function;
			var a:Number = (useEase) ? ease( weight, m1.a, m2.a - m1.a, 1 ) : m1.a + (m2.a - m1.a) * weight;
			var b:Number = (useEase) ? ease( weight, m1.b, m2.b - m1.b, 1 ) : m1.b + (m2.b - m1.b) * weight;
			var c:Number = (useEase) ? ease( weight, m1.c, m2.c - m1.c, 1 ) : m1.c + (m2.c - m1.c) * weight;
			var d:Number = (useEase) ? ease( weight, m1.d, m2.d - m1.d, 1 ) : m1.d + (m2.d - m1.d) * weight;
			var tx:Number = (useEase) ? ease( weight, m1.tx, m2.tx - m1.tx, 1 ) : m1.tx + (m2.tx - m1.tx) * weight;
			var ty:Number = (useEase) ? ease( weight, m1.ty, m2.ty - m1.ty, 1 ) : m1.ty + (m2.ty - m1.ty) * weight;
			
			return new Matrix(a,b,c,d,tx,ty);
		}
		
		/**
		 * rotationally interpolate between 2 Matrices.
		 * 
		 * @parm m1 - Start Matrix
		 * @param m2 - End Matrix
		 * @param weight - weight value from 0->1
		 * @param ease - if you want to use an easing function for interpolation, apply it here.
		 * 
		 * This is like lerpMatrix, but that it considers the rotational properties of the Matrix. This is useful 
		 * if you want the interpolation to effect rotation smoothly while retaining proper scale during it. This 
		 * stops unnexpected scaling, skewing, and clipping with lerpMatrix.
		 * 
		 * Use lerpMatrix if you want to interpolate skew and scale.
		 */
		public static function roterpMatrix( m1:Matrix, m2:Matrix, weight:Number, ease:Function=null ):Matrix
		{
			var useEase:Boolean = ease is Function;
			
			var a1:Number = LoDMatrixTransformer.getRotation(m1);
			var a2:Number = LoDMatrixTransformer.getRotation(m2);
			var ang:Number = LoDMath.interpolateAngles(a1, a2, weight, true, ease);
			
			var sx1:Number = LoDMatrixTransformer.getScaleX(m1);
			var sx2:Number = LoDMatrixTransformer.getScaleY(m2);
			var sx:Number = (useEase) ? ease( weight, sx1, sx2 - sx1, 1 ) : sx1 + (sx2 - sx1) * weight;
			
			var sy1:Number = LoDMatrixTransformer.getScaleY(m1);
			var sy2:Number = LoDMatrixTransformer.getScaleY(m2);
			var sy:Number = (useEase) ? ease( weight, sy1, sy2 - sy1, 1 ) : sy1 + (sy2 - sy1) * weight;
			
			var m:Matrix = new Matrix(sx, 0, 0, sy);
			LoDMatrixTransformer.setRotation( m, ang );
			m.tx = (useEase) ? ease( weight, m1.tx, m2.tx - m1.tx, 1 ) : m1.tx + (m2.tx - m1.tx) * weight;
			m.ty = (useEase) ? ease( weight, m1.ty, m2.ty - m1.ty, 1 ) : m1.ty + (m2.ty - m1.ty) * weight;
			
			return m;
		}
	}
}