package com.lordofduct.util
{
	public class LongInt
	{
		//this is used to temporarily convert a value of any type to a LongInt
		//this is used to keep memory down when doing long successions of math
		private static var _temp:LongInt = new LongInt();
		
		internal var _high:uint = 0;
		internal var _low:uint = 0;
		
		public function LongInt( value:*=null )
		{
			if(value)
			{
				this.setTo(value);
			}
		}
		
		public function add( value:* ):void
		{
			_temp.setTo( value );
			
			var ln:Number = _low + _temp._low;
			_low = ln & uint.MAX_VALUE;
			
			_high += ln / LoDMath.B_32;
			_high += _temp._high;
		}
		
		public function subtract( value:* ):void
		{
			_temp.setTo( value );
			var ln:Number = ~_temp._low + 1;
			var hn:Number = ~_temp._high;
			
			ln = _low + ln;
			_low = ln & uint.MAX_VALUE;
			
			_high += ln / LoDMath.B_32;
			_high += hn;
		}
		
		public function multiply( value:* ):void
		{
			_temp.setTo( value );
			
			var i:uint, mul:Number, mix:Number, ln:uint=0, hn:uint=0;
			
			for (i = 1<<31; i; i >>>= 1)
			{
				if(_temp._low & i)
				{
					mul = _low * i;
					ln += mul & uint.MAX_VALUE;
					
					hn += Math.floor( mul / LoDMath.B_32 );
					hn += _high * i;
				}
			}
			
			for (i = 1<<31; i; i >>>= 1)
			{
				if(_temp._high & i)
				{
					hn += _low * i;
				}
			}
			
			_low = ln;
			_high = hn;
		}
		
		public function divide( value:* ):void
		{
			_temp.setTo( value );
			
			var i:int, ln:Number, hn:Number, mix:Number;
			
			
		}
		
		public function equals( value:* ):Boolean
		{
			_temp.setTo( value );
			
			return (_high === _temp._high && _low === _temp._low);
		}
		
		public function setTo( value:* ):void
		{
			//if the value is a LongInt, then don't perform all the String parsing
			if(value is LongInt)
			{
				_high = value._high;
				_low = value._low;
				return;
			}
			
			
			var radix:int = 10;
			var val:String = LoDNumberUtils.cutValueFrom( value.toString(), radix );
			
			var isNeg:Boolean = false;
			if(val.substr(0,1) == "-")
			{
				isNeg = true;
				val = val.substr(1);
			}
			
			
			var cluster:int = Math.ceil(LoDMath.logBaseOf(uint.MAX_VALUE, radix));
			var ls:String = val.slice(-cluster);
			var hs:String = val.slice(0,-cluster);
			
			var ln:Number = parseInt(ls,radix);
			var hn:Number = parseInt(hs,radix);
			if(isNaN(ln)) ln = 0;
			if(isNaN(hn)) hn = 0;
			
			hn *= Math.pow(radix, cluster);
			var mix:Number = ((hn / LoDMath.B_32) % 1) * LoDMath.B_32;
			ln += mix;
			hn -= mix;
			
			mix = Math.floor(ln / LoDMath.B_32) * LoDMath.B_32;
			ln -= mix;
			hn += mix;
			
			hn /= LoDMath.B_32;
			
			_low = ln;
			_high = hn;
			
			if(isNeg)
			{
				_high = ~_high;
				_low = ~_low + 1;
			}
		}
		
		public function toString(radix:int=10):String
		{
			if(!_high && !_low) return "0";
			
			var isNeg:Boolean = Boolean(_high & (1 << 31));
			var ln:Number;
			var hn:Number;
			if(isNeg)
			{
				ln = ~_low + 1;
				hn = ~_high;
			} else {
				ln = _low;
				hn = _high & (uint.MAX_VALUE >>> 1);
			}
			
			hn *= LoDMath.B_32;
			var str:String = "";
			
			var sig:int = Math.ceil(LoDMath.logBaseOf( LoDMath.B_64, radix ));
			
			for (var i:int = 0; i < sig; i++)
			{
				var place:Number = Math.pow(radix, i);//what place are we in?
				var vp:Number = Math.floor(ln / place) + Math.floor(hn / place);
				vp %= radix;
				
				str = vp.toString(radix) + str;
			}
			
			while(str.charAt(0) == "0") str = str.slice(1);
			
			if(isNeg) str = "-" + str;
			
			return str;
		}
		
		public static function convertToLong( value:*, radix:uint=10 ):LongInt
		{
			if( value is LongInt) return value as LongInt;
			if( value is Number) return parseLong( value.toString(8), 8 );
			else return parseLong( value, radix );
		}
		
		public static function parseLong( value:String, radix:uint=2 ):LongInt
		{
			value = LoDNumberUtils.cutValueFrom( value, radix );
			
			var isNeg:Boolean = false;
			if(value.substr(0,1) == "-")
			{
				isNeg = true;
				value = value.substr(1);
			}
			
			var cluster:int = Math.ceil(LoDMath.logBaseOf(uint.MAX_VALUE, radix));
			var ls:String = value.slice(-cluster);
			var hs:String = value.slice(0,-cluster);
			
			var ln:Number = parseInt(ls,radix);
			var hn:Number = parseInt(hs,radix);
			if(isNaN(ln)) ln = 0;
			if(isNaN(hn)) hn = 0;
			
			hn *= Math.pow(radix, cluster);
			var mix:Number = ((hn / LoDMath.B_32) % 1) * LoDMath.B_32;
			ln += mix;
			hn -= mix;
			
			mix = Math.floor(ln / LoDMath.B_32) * LoDMath.B_32;
			ln -= mix;
			hn += mix;
			
			hn /= LoDMath.B_32;
			
			var long:LongInt = new LongInt();
			long._high = hn;
			long._low = ln;
			
			if(isNeg)
			{
				long._high = ~long._high;
				long._low = ~long._low + 1;
			}
			
			return long;
		}
	}
}