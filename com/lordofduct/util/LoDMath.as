/**
 * LoDMath - written by Dylan Engelman a.k.a LordOfDuct
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
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class LoDMath
	{
/**
 * CONSTANTS
 */
		public static const PI:Number         = 3.141592653589793; //number pi
		public static const PI_2:Number       = 1.5707963267948965; //PI / 2 OR 90 deg
		public static const PI_4:Number       = 0.7853981633974483; //PI / 4 OR 45 deg
		public static const PI_8:Number       = 0.39269908169872413; //PI / 8 OR 22.5 deg
		public static const PI_16:Number      = 0.19634954084936206; //PI / 16 OR 11.25 deg
		public static const TWO_PI:Number     = 6.283185307179586; //2 * PI OR 180 deg
		public static const THREE_PI_2:Number = 4.7123889803846895; //3 * PI_2 OR 270 deg
		public static const E:Number          = 2.71828182845905; //number e
		public static const LN10:Number       = 2.302585092994046; //ln(10)
		public static const LN2:Number        = 0.6931471805599453; //ln(2)
		public static const LOG10E:Number     = 0.4342944819032518; //logB10(e)
		public static const LOG2E:Number      = 1.442695040888963387; //logB2(e)
		public static const SQRT1_2:Number    = 0.7071067811865476; //sqrt( 1 / 2 )
		public static const SQRT2:Number      = 1.4142135623730951; //sqrt( 2 )
		public static const DEG_TO_RAD:Number = 0.017453292519943294444444444444444; //PI / 180;
		public static const RAD_TO_DEG:Number = 57.295779513082325225835265587527; // 180.0 / PI;
		
		public static const B_16:Number = 65536;//2^16
		public static const B_32:Number = 4294967296;//2^32
		public static const B_48:Number = 281474976710656;//2^48
		public static const B_64:Number = 18446744073709551616;//2^64
		
		public static const ONE_THIRD:Number  = 0.333333333333333333333333333333333; // 1.0/3.0;
		public static const TWO_THIRDS:Number = 0.666666666666666666666666666666666; // 2.0/3.0;
		public static const ONE_SIXTH:Number  = 0.166666666666666666666666666666666; // 1.0/6.0;
		
		public static const COS_PI_3:Number   = 0.86602540378443864676372317075294;//COS( PI / 3 )
		public static const SIN_2PI_3:Number  = 0.03654595;// SIN( 2*PI/3 )
		
		public static const CIRCLE_ALPHA:Number = 0.5522847498307933984022516322796; //4*(Math.sqrt(2)-1)/3.0;
		
		public static const ON:Boolean  = true;
		public static const OFF:Boolean = false;
		
		public static const SHORT_EPSILON:Number   = 0.1;
		public static const EPSILON:Number         = 0.0001;
		public static const MACHINE_EPSILON:Number = computeMachineEpsilon();
		
		public static function computeMachineEpsilon():Number
		{
			// Machine epsilon ala Eispack
			var fourThirds:Number = 4.0/3.0;
			var third:Number      = fourThirds - 1.0;
			var one:Number        = third + third + third;
			return Math.abs(1.0 - one);
		}
		
/**
 * NO CONSTRUCTOR
 */
		public function LoDMath()
		{
			Assertions.throwError("com.lorofduct.util::LoDMath - can not instantiate static member class.", Error);
		}
		
		public static function fuzzyEqual( a:Number, b:Number, epsilon:Number=0.0001 ):Boolean
		{
			return Math.abs(a-b) < epsilon;
		}
		
		public static function fuzzyLessThan( a:Number, b:Number, epsilon:Number=0.0001 ):Boolean
		{
			return a < b + epsilon;
		}
		
		public static function fuzzyGreaterThan( a:Number, b:Number, epsilon:Number=0.0001 ):Boolean
		{
			return a > b - epsilon;
		}
		
		public static function average( ...args ):Number
		{
			var avg:Number = 0;
			for each( var value:Number in args )
			{
				avg += value;
			}
			return avg / args.length;
		}
		
		public static function slam( value:Number, target:Number, epsilon:Number = 0.0001 ):Number
		{
			return (Math.abs(value - target) < epsilon) ? target : value;
		}
		
		/**
		 * ratio of value to a range
		 */
		public static function percentageMinMax(val:Number, max:Number, min:Number = 0):Number
		{
			val -= min;
			max -= min;
			
			if (!max) return 0;
			else return val / max;
		}
		
		/**
		 * a value representing the sign of the value.
		 * -1 for negative, +1 for positive, 0 if value is 0
		 */
		public static function sign(n:Number): int
		{
			if (n) return n / Math.abs(n);
			else return 0;
		}
		
		/**
		 * wrap a value around a range, similar to modulus with a floating minimum
		 */
		public static function wrap(val:Number, max:Number, min:Number = 0):Number
		{
			val -= min;
			max -= min;
			val %= max;
			val += min;
			while (val < min)
				val += max;
			
			return val;
		}
		
		/**
		 * force a value within the boundaries of two values
		 * 
		 * if max < min, min is returned
		 */
		public static function clamp(input:Number, max:Number, min:Number = 0):Number
		{
        	return Math.max( min, Math.min( max, input ) );
        }

		/**
		 * a one dimensional linear interpolation of a value.
		 */
		public static function interpolateFloat(a:Number, b:Number, weight:Number):Number
		{
			return (b - a) * weight + a;
		}
		
		/**
		 * convert radians to degrees
		 */
		public static function radiansToDegrees( angle:Number ):Number
		{
			return angle * RAD_TO_DEG;
		}
		
		/**
		 * convert degrees to radians
		 */
		public static function degreesToRadians( angle:Number ):Number
		{
			return angle * DEG_TO_RAD;
		}
		
		/**
		 * Find the angle of a segment from (x1, y1) -> (x2, y2 )
		 */
		public static function angleBetween(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			return Math.atan2( y2 - y1, x2 - x1 );
		}
		
		
		/**
		 * set an angle with in the bounds of -PI to PI
		 */
		public static function normalizeAngle( angle:Number, radians:Boolean=true ):Number
		{
			var rd:Number = (radians) ? PI : 180;
			
			return wrap(angle, rd, -rd);
		}
		
		/**
		 * closest angle between two angles from a1 to a2
		 * absolute value the return for exact angle
		 */
		public static function nearestAngleBetween( a1:Number, a2:Number, radians:Boolean = true ):Number
		{
			var rd:Number = (radians) ? PI : 180;
			
			a1 = normalizeAngle( a1, radians );
			a2 = normalizeAngle( a2, radians );
			
			if( a1 < -rd / 2 && a2 > rd / 2 ) a1 += rd * 2;
			if( a2 < -rd / 2 && a1 > rd / 2 ) a2 += rd * 2;
			
			return a2 - a1;
		}
		
		/**
		 * normalizes independent and then sets dep to the nearest value respective to independent
		 * 
		 * for instance if dep=-170 and ind=170 then 190 will be returned as an alternative to -170
		 */
		public static function normalizeAngleToAnother( dep:Number, ind:Number, radians:Boolean=true ):Number
		{
			return ind + nearestAngleBetween( ind, dep, radians );
		}
		
		/**
		 * interpolate across the shortest arc between two angles
		 */
		public static function interpolateAngles( a1:Number, a2:Number, weight:Number, radians:Boolean = true ):Number
		{
			a1 = normalizeAngle( a1, radians );
			a2 = normalizeAngleToAnother( a2, a1, radians );
			
			return interpolateFloat( a1, a2, weight );
		}
		
		/**
		 * Compute the logarithm of any value of any base
		 * 
		 * a logarithm is the exponent that some constant (base) would have to be raised to 
		 * to be equal to value.
		 * 
		 * i.e.
		 * 4 ^ x = 16
		 * can be rewritten as to solve for x
		 * logB4(16) = x
		 * which with this function would be 
		 * LoDMath.logBaseOf(16,4)
		 * 
		 * which would return 2, because 4^2 = 16
		 */
		public static function logBaseOf( value:Number, base:Number ):Number
		{
			return Math.log(value) / Math.log(base);
		}
		
/**
 * Awkward math methods
 */	
		/**
		 * Returns a new Rectangle describing the bounds of a Rectangle transformed by a Matrix. 
		 * This will include rotation, translation, skewing, and scaling.
		 */
		public static function transformRectByMatrix( rect:Rectangle, matrix:Matrix ):Rectangle
		{
			var rtl:Point = matrix.transformPoint( rect.topLeft );
			var rbl:Point = matrix.transformPoint( new Point( rect.left, rect.bottom ) );
			var rbr:Point = matrix.transformPoint( rect.bottomRight );
			var rtr:Point = matrix.transformPoint( new Point( rect.right, rect.top ) );
			
			var left:Number = Math.min( rtl.x, rbl.x, rbr.x, rtr.x );
			var right:Number = Math.max( rtl.x, rbl.x, rbr.x, rtr.x );
			var top:Number = Math.min( rtl.y, rbl.y, rbr.y, rtr.y );
			var bottom:Number = Math.max( rtl.y, rbl.y, rbr.y, rtr.y );
			
			return new Rectangle( left, top, right - left, bottom - top );
		}
		
		/**
		 * Check if a value is prime.
		 * 
		 * @param val - uint to check for primality
		 * 
		 * In this method to increase speed we first check if the value is <= 1, because values <= 1 are not prime by definition. 
		 * Then we check if the value is even but not equal to 2. If so the value is most certainly not prime. 
		 * Lastly we loop through all odd divisors. No point in checking 1 or even divisors, because if it were divisible by an even 
		 * number it would be divisible by 2. If any divisor existed when i > value / i then its compliment would have already 
		 * been located. And lastly the loop will never reach i == val because i will never be > sqrt(val).
		 * 
		 * proof of validity for algorithm:
		 * 
		 * all trivial values are thrown out immediately by checking if even or less then 2
		 * 
		 * all remaining possibilities MUST be odd, an odd is resolved as the multiplication of 2 odd values only. (even * any value == even)
		 * 
		 * in resolution a * b = val, a = val / b. As every compliment a for b, b and a can be swapped resulting in b being <= a. If a compliment for b 
		 * exists then that compliment would have already occured (as it is odd) in the swapped addition at the even split.
		 * 
		 * Example...
		 * 
		 * 16
		 * 1 * 16
		 * 2 * 8
		 * 4 * 4
		 * 8 * 2
		 * 16 * 1
		 * 
		 * checks for 1, 2, and 4 would have already checked the validity of 8 and 16.
		 * 
		 * Thusly we would only have to loop as long as i <= val / i. Once we've reached the middle compliment, all subsequent factors have been resolved.
		 * 
		 * This shrinks the number of loops for odd values from [ floor(val / 2) - 1 ] down to [ max( 1, floor(sqrt(val) / 2) - 1) ]
		 * 
		 * example, if we checked EVERY odd number for the validity of the prime 7927, we'd loop 3962 times
		 * 
		 * but by this algorithm we loop only 43 times. Significant improvement!
		 */
		static public function isPrime( val:int ):Boolean
		{
			//check if value is in prime number range
			if (val < 2) return false;
			
			//check if even, but not equal to 2
			if (!(val % 2) && val != 2) return false;
			
			//if 2 or odd, check if any nontrivial divisor exists
			for (var i:int = 3; i <= val / i; i += 2)
			{
				if (!(val % i)) return false;
			}
			
			return true;
		}
		
		/**
		 * Returns all factors of a value as positive integers. Negative integers are excluded as the sign is assumed to be relative.
		 * 
		 * for efficiency we use the same analytical algorithm from isPrime where we only check while i <= val / i. We test both odds and evens now though 
		 * as we haven't thrown out all trivial values. Still the same concept applies. Which means all primes of 16 can be found by the time i reach 4, instead of 
		 * having to loop all the way to 16.
		 * 
		 * @param val - the integer to find all factors of
		 * 
		 * @return Array - an Array sorted numerically ascending of all factors for a value.
		 */
		static public function factorsOf( val:int ):Array
		{
			val = Math.abs(val);
			var arr:Array = new Array();
			
			for ( var i:int = 1; i <= val / i; i++ )
			{
				if(!(val % i))
				{
					arr.push( i );
					arr.push( val / i );
				}
			}
			
			arr.sort( Array.NUMERIC );
			return arr;
		}
		
/**
 * Advanced Math
 */
	}
}