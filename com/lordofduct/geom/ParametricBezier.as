/**
 * NOT FUNCTIONING PROPERLY
 */

package com.lordofduct.geom
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	
	import flash.geom.Point;

	public class ParametricBezier implements IParametric
	{
		private var _cX:Array;
		private var _cY:Array;
		
		public function ParametricBezier()
		{
			_cX = new Array();
			_cY = new Array();
		}
		
/**
 * IParametric Interface
 */
		/**
		 * Add a control point to the Parametric curve
		 * 
		 * ...args set up
		 * for coords - ..., xCoord:Number, yCoord )
		 * for Point, Point2D, or Object - ..., pnt:* )
		 */
		public function addControlCoord(...args):void
		{
			if(args[0] is Point || args[0] is Point2D)
			{
				_cX.push(args[0].x);
				_cY.push(args[0].y);
			}
			else
			{
				_cX.push(args[0] as Number);
				_cY.push(args[1] as Number);
			}
		}
		
		/**
		 * Move a control point from the Parametric curve
		 * 
		 * ...args set up
		 * for coords - ..., xCoord:Number, yCoord )
		 * for Point, Point2D, or Object - ..., pnt:* )
		 */
		public function moveControlCoord(index:uint, ...args):void
		{
			Assertions.isNotTrue( index >= _cX.length, "com.lordofduct.geom::ParametricBezier - can not move point that does not exist" );
			
			if(args[0] is Point || args[0] is Point2D)
			{
				_cX[index] = args[0].x;
				_cY[index] = args[0].y;
			}
			else
			{
				_cX[index] = args[0] as Number;
				_cY[index] = args[1] as Number;
			}
		}
		
		/**
		 * Get a control point
		 */
		public function getControlCoord(index:uint):Point
		{
			return new Point( _cX[index], _cY[index] );
		}
		
		/**
		 * Remove a control point, all following control points shift 1 space back 
		 * and the index for all subsequent points shifts back 1
		 */
		public function removeControlCoord(index:uint):void
		{
			_cX.splice(index,1);
			_cY.splice(index,1);
		}
		
		/**
		 * Compute and return the arc length of a curve. This tends to be very heavy work 
		 * so run this method as little as possible. Consider recording this value some where 
		 * and updating it whenever alterations are made to the curve.
		 */
		public function arcLength():Number
		{
			return 0;
		}
		
		/**
		 * Remove all control points and reset for reuse
		 */
		public function reset():void
		{
			_cX.length = 0;
			_cY.length = 0;
		}
		
		public function getPosition(t:Number):Point
		{
			return this.computeNaivePosition(t);
		}
		
		public function getX(t:Number):Number
		{
			return this.computeNaiveX(t);
		}
		
		public function getY(t:Number):Number
		{
			return this.computeNaiveY(t);
		}
		
		public function getPrimePosition(t:Number):Point
		{
			return new Point(getPrimeX(t), getPrimeY(t));
		}
		
		public function getPrimeX(t:Number):Number
		{
			return 0;
		}
		
		public function getPrimeY(t:Number):Number
		{
			return 0;
		}
		
/**
 * Naive Formulae of Bezier @private
 * 
 * algorithm by Dylan Engelman
 */
		private function computeNaivePosition(t:Number):Point
		{
			return new Point( computeNaiveX(t), computeNaiveY(t) );
		}
		
		private function computeNaiveX(t:Number):Number
		{
			var arr:Array = _cX.slice();
			
			while( arr.length > 1 )
			{
				for (var i:int = 1; i < arr.length; i++)
				{
					arr[i-1] = LoDMath.interpolateFloat(arr[i-1], arr[i], t);
				}
				
				arr.pop();
			}
			
			return arr.pop();
		}
		
		private function computeNaiveY(t:Number):Number
		{
			var arr:Array = _cY.slice();
			
			while( arr.length > 1 )
			{
				for (var i:int = 1; i < arr.length; i++)
				{
					arr[i-1] = LoDMath.interpolateFloat(arr[i-1], arr[i], t);
				}
				
				arr.pop();
			}
			
			return arr.pop();
		}
		
/**
 * Coefficient Formulae of Bezier @private
 * 
 * algorithm by Jim Armstrong of www.algorithmist.com
 * 
 * all rights reserved
 */
		private function computeCoefPosition(t:Number):Point
		{
			return null;
		}
		
		private function computeCoefX(t:Number):Number
		{
			return 0;
		}
		
		private function computeCoefY(t:Number):Number
		{
			return 0;
		}
	}
}