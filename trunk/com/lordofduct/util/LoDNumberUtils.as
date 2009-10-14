package com.lordofduct.util
{
	public class LoDNumberUtils
	{
		public function LoDNumberUtils()
		{
		}
		
		public static function toLength( value:uint, length:int ):String
		{
			var str:String = value.toString();
			
			while(str.length < length) str = "0" + str;
			
			return str;
		}
		
		/**
		 * Converts a Number to a 16.16 fixed-point binary value stored in a signed integer
		 */
		public static function floatTo1616Fixed( value:Number ):int
		{
			return value * 0x10000;
		}
		
		public static function floatFrom1616Fixed( value:int ):Number
		{
			return value / 0x10000;
		}
		
		/**
		 * Converts a Number to a 8.24 fixed-point binary value stored in a signed integer
		 */
		public static function floatTo824Fixed( value:Number ):int
		{
			return value * 0x1000000;
		}
		
		public static function floatFrom824Fixed( value:int ):Number
		{
			return value / 0x1000000;
		}
		
		/**
		 * Converts a Number to a 24.8 fixed-point binary value stored in a signed integer
		 */
		public static function floatTo248Fixed( value:Number ):int
		{
			return value * 0x100;
		}
		
		public static function floatFrom248Fixed( value:int ):Number
		{
			return value / 0x100;
		}
		
		/**
		 * Converts a Number to a Twip (1/20th) stored in a signed integer
		 */
		public static function floatToTwip( value:Number ):int
		{
			return value * 20;
		}
		
		public static function floatFromTwip( value:int ):Number
		{
			return value / 20;
		}
		
		public static function cutValueFrom( value:String, radix:uint ):String
		{
			Assertions.betweenOrEqual( radix, 2, 36, "com.lordofduct.util::LoDNumberUtils - radix must be between 2 and 36" );
			
			var result:String = "";
			
			//clear leading whitespace
			value = value.replace(new RegExp("^[ \s]+"), "");
			
			//check if negative
			if(value.charAt(0) == "-")
			{
				value = value.substr(1);
				result = "-";
			}
			
			//now grab all numeric values up to anything that fails
			var regs:String = "^[0-";
			if(radix < 11) regs += (radix - 1).toString();
			else {
				regs += "9";
				
				var sub:String = "a-";
				var alpha:Array = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" ];
				sub += alpha[ radix - 10 ];
				
				regs += sub;
				regs += sub.toUpperCase();
			}
			
			regs += "]+";
			var match:Array = value.match( new RegExp(regs) );
			if(!match) return "";
			
			result += match[0];
			return result;
		}
	}
}