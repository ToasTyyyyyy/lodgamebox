/**
 * NOT FUNCTIONING PROPERLY
 */

package com.lordofduct.geom
{
	import flash.geom.Point;

	public class ParametricCatmullRom implements IParametric
	{
		public function ParametricCatmullRom()
		{
		}

		public function addControlCoord(...args):void
		{
		}
		
		public function moveControlCoord(index:uint, ...args):void
		{
		}
		
		public function getControlCoord(index:uint):Point
		{
			return null;
		}
		
		public function removeControlCoord(index:uint):void
		{
		}
		
		public function arcLength():Number
		{
			return 0;
		}
		
		public function reset():void
		{
		}
		
		public function getPosition(t:Number):Point
		{
			return null;
		}
		
		public function getX(t:Number):Number
		{
			return 0;
		}
		
		public function getY(t:Number):Number
		{
			return 0;
		}
		
		public function getPrimePosition(t:Number):Point
		{
			return null;
		}
		
		public function getPrimeX(t:Number):Number
		{
			return 0;
		}
		
		public function getPrimeY(t:Number):Number
		{
			return 0;
		}
		
	}
}