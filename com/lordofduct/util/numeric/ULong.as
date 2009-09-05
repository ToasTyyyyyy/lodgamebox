package com.lordofduct.util.numeric
{
	import com.lordofduct.util.LoDMath;
	
	public class ULong
	{
		private var _low:Number=0;
		private var _high:Number=0;
		
		/**
		 * Constructor
		 * 
		 * value must be passed in binary notation with out the leading 0x
		 * 
		 * example:
		 * 
		 * var num:Number = 64006434;
		 * var long:ULong = new ULong( num.toString(2) );
		 */
		public function ULong( value:String, radix:uint=16 )
		{
			this.setValue(value, radix);
		}
		
		public function setValue( value:*, radix:uint=16 ):void
		{
			var arr:Array = this.decipherObject( value, radix );
			_high = arr[0];
			_low = arr[1];
		}
		
		public function toString(radix:uint=10):String
		{
			//TODO check out LoDMath
			
			return "ha";
		}
		
/**
 * Private interface
 */
		private function decipherObject( value:*, radix:uint=16 ):Array
		{
			if(value is ULong || value is Number)
			{
				return this.decipherObject(value.toString(16), 16);
			} else 
			{
				//TODO check out LODMath
			}
		}
	}
}