package com.lordofduct.util
{
	public class LoDRandom
	{
		public function LoDRandom()
		{
		}
		
		/**
		 * Random Number between minimum and maximum
		 */
		public static function randomMinMax(max:Number, min:Number = 0):Number
		{
			return Math.random() * (max - min) + min;
		}
		
		//returns a random integer between min and max - 1
		public static function randomIntMinMax(max:int, min:int = 0):int
		{
			return Math.floor(Math.random() * (max - min)) + min;
		}
		
		//returns a value between -1 and +1
		public static function randomN1P1(...args):Number
		{
			return Math.random() * 2 - 1;
		}
		
		//returns either 0 or 1
		public static function randomPop(...args):int
		{
			return Math.round(Math.random());
		}
		
		//kind of like randomPop, but returns the value as a Boolean
		public static function randomBool(...args):Boolean
		{
			return Boolean(randomPop());
		}
		
		//return either -1 or +1... good for "flipping" values randomly
		public static function randomFlip(...args):int
		{
			if ( randomBool() ) return 1;
			else return -1;
		}
		
		//returns a random angle in radians from -pi to +pi
		public static function randomAngle(...args):Number
		{
			return Math.random() * 2 * Math.PI - Math.PI;
		}
		
		//returns -1, 0, or 1 randomly. This can be used for bizarre things like randomizing an array
		public static function randomShift(...args):int
		{
			return randomIntMinMax( 1, -1 );
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