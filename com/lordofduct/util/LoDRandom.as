package com.lordofduct.util
{
	public class LoDRandom
	{
		public function LoDRandom()
		{
		}
		
		/**
		 * Random Number between minimum and maximum
		 * 
		 * @param - max - maximum value in range
		 * @param - min - minimum value in range, default 0
		 * 
		 * @return Number - a value in the range
		 * 
		 * Because Math.random is a random number generator the value it creates is a value from 0.0...1->0.9999. This allows 
		 * for easy probability dispersment across discrete and continuous mathematics. Similarily the value 0 isn't created either. 
		 * This means that the actual min and max value won't ever be created as whole values... you'll probably get something really 
		 * close, or a rare chance of it occuring due to float error and rounding. So don't expect to ever get the actual min or max values.
		 */
		public static function randomMinMax(max:Number, min:Number = 0):Number
		{
			return Math.random() * (max - min) + min;
		}
		
		/**
		 * Random Number between min and max. This time though we consider the 'last' value generated in the range. It then makes sure not 
		 * to return a value near the 'last' value considering some padding.
		 * 
		 * ex:
		 * If the last value received was 6 in a range of 0 to 20. And we don't want any values within 2 units of 6 (from 4 to 8)... this will 
		 * return ONLY values from 0->4 OR 8->20... with equal probability as well.
		 * 
		 * in code:
		 * var newValue:Number = LoDRandom.randomNextMinMax(6, 2, 20, 0);
		 */
		public static function randomNextMinMax(last:Number, pad:Number, max:Number, min:Number = 0):Number
		{
			if (max < min) pad = -pad;
			
			var midax:Number =Math.max( min, Math.min( max, last + pad ) );
			var midin:Number = Math.max( min, Math.min( max, last - pad ) );
			var h:Number = max - midax;
			var l:Number = midin - min;
			var gap:Number = l + h;
			gap *= Math.random();
			if( gap >= l ) gap += (midax - midin);
			
			return gap + min;
		}
		
		/**
		 * Random int between min and max
		 * 
		 * @param max - maximum value in range
		 * @param min - minimum value in range, default 0
		 * @param inclusive - include 'max' in the range. If false return value is from min -> max - 1. If true return value is from min -> max
		 * 
		 * @return int - a value in the range
		 * 
		 * The inclusive param is due to probability managing. If we were to use Math.round the probability of min and max would be half that of 
		 * all other values. If it were Math.ceil then min would not be included. If it were Math.floor then max would not be included. 
		 * 
		 * To resolve this we add one to the range length (max - min + 1) and use floor. This makes all values from min to max all inclussive. 
		 * But there are scenarios where the exclussion of max is very useful, for instance with 0 based indices like that of an Array. Because 
		 * 0 based indices are very common I set the inclussion of 'max' to false.
		 */
		public static function randomIntMinMax(max:int, min:int = 0, inclusive:Boolean=false):int
		{
			return Math.floor(Math.random() * (max - min + int(inclusive))) + min;
		}
		
		/**
		 * Random Number from -1 to +1
		 * 
		 * @param ...args - this is just a safe capture if this function is passed to an Array.sort function or something similar
		 * 
		 * @return Number - a value from -1 to +1 (non inclussive)
		 * 
		 * This function is a speedier version of randomMaxMin( 1, -1 ). It's useful as a percentage scalar over two directions. 
		 * Think of this as Math.random() which return 0->0.9999, this will return -1->1... the principal as an interpolative is there.
		 */
		public static function randomN1P1(...args):Number
		{
			return Math.random() * 2 - 1;
		}
		
		/**
		 * Random int 0 or 1
		 * 
		 * @param ...args - this is just a safe capture if this function is passed to an Array.sort function or something similar
		 * 
		 * @return int - either 0 or 1
		 * 
		 * This generates either 0 or 1 randomly. What else do you expect
		 */
		public static function randomPop(...args):int
		{
			return Math.round(Math.random());
		}
		
		/**
		 * Random Boolean
		 * 
		 * @param ...args - this is just a safe capture if this function is passed to an Array.sort function or something similar
		 * 
		 * @return Boolean - either true or false
		 * 
		 * This generates either true or false. It's very similar to randomPop(...), but instead it's returned as a Boolean for safe typing. 
		 */
		public static function randomBool(...args):Boolean
		{
			return Boolean( Math.round(Math.random()) );
		}
		
		
		//return either -1 or +1... good for "flipping" values randomly
		public static function randomFlip(...args):int
		{
			var n:int = Math.round(Math.random());
			
			return n + n - 1;
		}
		
		//returns a random angle in radians from -pi to +pi
		public static function randomAngle(...args):Number
		{
			return Math.random() * 2 * Math.PI - Math.PI;
		}
		
		//returns -1, 0, or 1 randomly. This can be used for bizarre things like randomizing an array
		public static function randomShift(...args):int
		{
			return randomIntMinMax( 1, -1, true );
		}
		
		/**
		 * Creates an array of length numEntries where each value is generated by the function passed and no repeating value is kept
		 * 
		 * @param numEntries - how many values should be generated, should be > 0
		 * @param funct - the function to generate the value from. Should use the functions from RandomHelper class
		 * @param params - an array of the params to pass to the function we're using. For instance if you pass RandomHelper.randomMinMax, params could be [ 0, 10 ]
		 * @param numAttempts - the number of times to attempt to locate a unique value that pass, if no unique value is created, then the last value created is pushed into the array.
		 * 
		 * Warning - if the function passed creates a discrete limit of values, numEntries should not exceed the discrete limit of that function. 
		 * If the discrete limit is less then numEntries then the list will no longer be discrete and numAttempts captures these none-unique values. 
		 * Passing 0 as numAttempts will allow you to efficiently create a none unique random list. 
		 */
		public static function uniqueList( numEntries:int, funct:Function, params:Array, numAttempts:int=10 ):Array
		{
			var arr:Array = new Array();
			
			var tries:int = 0;
			
			while( arr.length < numEntries )
			{
				var value:* = funct.apply( null, params );
				if (arr.indexOf( value ) < 0)
				{
					arr.push( value );
					tries = 0;
				} else {
					tries++;
					if (tries > numAttempts) arr.push( value );
				}
			}
			
			return arr;
		}
		
		/**
		 * Returns a copy of the passed array in a random order
		 */
		public static function randomizeArray( arr:Array ):Array
		{
			var rtn:Array = arr.slice();
			
			rtn.sort( randomShift );
			
			return rtn;
		}
		
		/**
		 * Shuffle a number of arrays together where the result is:
		 * 
		 * [ a[0], b[0], a[1], b[1], a[2], b[2] ]
		 */
		public static function shuffleTogether( a:Array, b:Array, ...args ):Array
		{
			args.unshift(b);
			args.unshift(a);
			var l:int=0, i:int;
			
			for( i = 0; i < args.length; i++)
			{
				if (args[i].length > l) l = args[i].length;
			}
		
			b = [];
		
			for(i = 0; i < l; i++)
			{
				for each(a in args)
				{
					if(a.length < i) b.push(a[i]);
				}
			}
		
			return b;
		}
		
		public static function selectRandomly( values:Array, odds:Array=null ):Object
		{
			if(!values || !values.length) return null;
			
			if(odds && odds.length == values.length)
			{
				var r:Number = Math.random();
				var index:int = -1;
				
				while( r > 0 && index != values.length )
				{
					index++;
					r -= odds[index];
				}
				
				if (index < values.length) return values[index];
			}
			
			return values[ randomIntMinMax( values.length ) ];
		}
	}
}