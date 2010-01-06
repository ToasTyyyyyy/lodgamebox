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
			if(radix < 11) regs += LoDNumberUtils.getMaxAlphaNumericSymbolForBase(radix);
			else {
				regs += "9";
				
				var sub:String = "a-";
				sub += LoDNumberUtils.getMaxAlphaNumericSymbolForBase(radix);
				
				regs += sub;
				regs += sub.toUpperCase();
			}
			
			regs += "]+";
			var match:Array = value.match( new RegExp(regs) );
			if(!match) return "";
			
			result += match[0];
			return result;
		}
		
		public static function getMaxAlphaNumericSymbolForBase( base:int ):String
		{
			if(base > 36 || base < 1) return null;
			
			if( base < 11 ) return int(base - 1).toString();
			else
			{
				base -= 11;
				
				switch( base )
				{
					case 0: return "a"; break;
					case 1: return "b"; break;
					case 2: return "c"; break;
					case 3: return "d"; break;
					case 4: return "e"; break;
					case 5: return "f"; break;
					case 6: return "g"; break;
					case 7: return "h"; break;
					case 8: return "i"; break;
					case 9: return "j"; break;
					case 10: return "k"; break;
					case 11: return "l"; break;
					case 12: return "m"; break;
					case 13: return "n"; break;
					case 14: return "o"; break;
					case 15: return "p"; break;
					case 16: return "q"; break;
					case 17: return "r"; break;
					case 18: return "s"; break;
					case 19: return "t"; break;
					case 20: return "u"; break;
					case 21: return "v"; break;
					case 22: return "w"; break;
					case 23: return "x"; break;
					case 24: return "y"; break;
					case 25: return "z"; break;
				}
			}
		}
		
/**
 * Bit Helpers
 */
	/**
	 * ARGB Colour Helpers
	 */
		public static function colorsToARGB( r:int, g:int, b:int, alpha:int=0xFF ):uint
		{
			return (alpha << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
		}
		
		public static function colorsToRGB( r:int, g:int, b:int ):uint
		{
			return ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
		}
		
		public static function extractAlpha( value:uint ):uint
		{
			return value >>> 24;
		}
		
		public static function extractRed( value:uint ):uint
		{
			return (value >> 16) & 0xFF;
		}
		
		public static function extractGreen( value:uint ):uint
		{
			return (value >> 8) & 0xFF;
		}
		
		public static function extractBlue( value:uint ):uint
		{
			return value & 0xFF;
		}
		
	/**
	 * Masking
	 */
		/**
		 * Build a mask over a range.
		 * 
		 * @param low - the low end bit start position (near 0)
		 * @param high - the high end bit end position (near uint.MAX_VALUE)
		 * 
		 * params should be between 1 -> 32 for each available bit of a 32-bit uint. 
		 * Where one represents near 0, and 32 represent near uint.MAX_VALUE.
		 * 
		 * ex:
		 * 
		 * trace( LoDNumberUtils.buildRangeMask( 3, 5 ).toString(2) ); //traces: 11100
		 */
		public static function buildRangeMask( low:int, high:int ):int
		{
			return uint(Math.pow(2, high) - 1) & ~uint(Math.pow(2, low - 1) - 1);
		}
		
		/**
		 * Replaces a range of bits of some value with the same range of bits of another value
		 * 
		 * @param toReplace - the value getting written over
		 * @param replaceWith - the value getting written to toReplace
		 * @param mask - a mask representing the bits to replace
		 * 
		 * ex:
		 * 
		 * var mask:uint = LoDNumberUtils.buildRangeMask( 9, 16 );//get 11111100
		 * var toReplace:uint = 0xFFFFFFFF;
		 * var replaceWith:uint = 0xAC00;
		 * trace( LoDNumberUtils.replaceOver( toReplace, replaceWith, mask ).toString(16) );//traces: FFFFACFF
		 */
		public static function replaceBitsOver( toReplace:int, replaceWith:int, mask:uint ):int
		{
			return (toReplace & ~mask) | (replaceWith & mask);
		}
		
		public static function andBitsOver( left:int, right:int, mask:int ):int
		{
			return ( left & ~mask ) | ( (left & right) & mask );
		}
		
		public static function negateBitsOver( value:int, mask:int ):int
		{
			return (value & ~mask) | ~(value & mask);
		}
		
		public static function orBitsOver( left:int, right:int, mask:int ):int
		{
			return ( left & ~mask ) | ( (left | right) & mask );
		}
		
		public static function xorBitsOver( left:int, right:int, mask:int ):int
		{
			return ( left & ~mask ) | ( (left ^ right) & mask );
		}
		
		public static function zeroBitsOver( value:int, mask:int ):int
		{
			return value & ~mask;
		}
		
	/**
	 * Bit shifts and moves
	 */
		public static function rotateBits( value:int, mask:int = -1 ):int
		{
			//resolve the sign first
			var rtn:int = (value < 0) ? 1 : 0;
			
			//take the low 31 bits
			for( var i:int = 0; i < 31; i++ )
			{
				rtn = (rtn << 1) | ((value >>> i) & 1);
			}
		}
		
		public static function unsignedRotateBits( value:int ):int
		{
			//set zero
			var rtn:int = 0;
			
			//take all 32 bits from low to high
			for( var i:int = 0; i < 32; i++ )
			{
				//first shift rtn left 1 bit, then OR on the bit in position i
				rtn = (rtn << 1) | ((value >>> i) & 1);
			}
		}
		
		public static function rotateBytes( value:uint ):uint
		{
			return ((value & 0xFF) << 24) | (((value >> 8) & 0xFF) << 16) | (((value >> 16) & 0xFF) << 8) | (value >>> 24);
		}
		
		public static swapBits( value:int, pos1:int, pos2:int ):int
		{
			//zero index the positions
			pos1--;
			pos2--;
			//grab masks and values
			var ma:int = Math.pow(2, pos1);
			var mb:int = Math.pow(2, pos2);
			var mc:int = ma | mb;
			var a:int = (value & ma) >>> (pos1);
			var b:int = (value & mb) >>> (pos2);
			
			return (value & ~mc) | (b << pos1) | (a << pos2);
		}
	}
}