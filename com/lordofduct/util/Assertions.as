/**
 * Assertions - written by Dylan Engelman a.k.a LordOfDuct
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
	public class Assertions
	{
		public function Assertions()
		{
			Assertions.throwError("com.lorofduct.util::Assertions - can not instantiate static member class.", Error);
		}
		
/**
 * Class Definitions
 */
		public static function throwError( message:String, exceptionType:Class=null ):void
		{
			switch(exceptionType)
			{
				case null : throw new ArgumentError(message); break;
				default : throw new exceptionType(message); break;
			}
		}
		
		public static function isTrue( bool:Boolean, message:String=null, exceptionType:Class=null ):Boolean
		{
			if(message && !bool) throwError(message,exceptionType);
			return bool;
		}
		
		public static function allAreTrue( arr:Array, message:String=null, exceptionType:Class=null ):Boolean
		{
			var bool:Boolean = false;
			
			for each(var obj:* in arr)
			{
				bool = isTrue(obj, message, exceptionType);
			}
			
			return bool;
		}
		
		public static function isNotTrue( bool:Boolean, message:String=null, exceptionType:Class=null ):Boolean
		{
			if(message && bool) throwError(message,exceptionType);
			return !bool;
		}
		
		public static function allAreNotTrue( arr:Array, message:String=null, exceptionType:Class=null ):Boolean
		{
			var bool:Boolean = false;
			
			for each(var obj:* in arr)
			{
				bool = isNotTrue(obj, message, exceptionType);
			}
			
			return bool;
		}
		
		/**
		 * Assert that a value is greater than a minimum number.
		 * 
		 * @param value The value to test.
		 * @param minimum The minimum number that the value must be greater than.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function greater(value:Number, minimum:Number=-1,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(value <= minimum) throwError(message,exceptionType);
			return (value > minimum);
		}
		
		public static function greaterOrEqual(value:Number, minimum:Number=-1,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(value < minimum) throwError(message,exceptionType);
			return (value >= minimum);
		}
		
		/**
		 * Assert that a value is smaller than a maximum number.
		 * 
		 * @param value The value to test.
		 * @param maximum The maximum number that the value must be smaller than.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function smaller(value:Number,maxmimum:Number=0,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(value >= maxmimum) throwError(message,exceptionType);
			return (value < maxmimum);
		}
		
		public static function smallerOrEqual(value:Number,maxmimum:Number=0,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(value > maxmimum) throwError(message,exceptionType);
			return (value <= maxmimum);
		}
		
		public static function between( value:Number, low:Number=Number.MIN_VALUE, high:Number=Number.MAX_VALUE, message:String=null, exceptionType:Class=null):Boolean
		{
			if(message) if(value <= low || value >= high) throwError( message, exceptionType );
			return (value > low && value < high);
		}
		
		public static function betweenOrEqual( value:Number, low:Number=Number.MIN_VALUE, high:Number=Number.MAX_VALUE, message:String=null, exceptionType:Class=null):Boolean
		{
			if(message) if(value < low || value > high) throwError( message, exceptionType );
			return (value >= low && value <= high);
		}
		
		/**
		 * Assert that a value is equal to another value.
		 * 
		 * @param value The value to test.
		 * @param otherValue The other value to compare with value (this is actually typed as &#42;, but asdocs changes it to String for some reason).
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function equal(value:*,otherValue:*,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(value!==otherValue) throwError(message,exceptionType);
			return (value===otherValue);
		}
		
		/**
		 * Assert that a value is defferent from another value.
		 * 
		 * @param value The value to test.
		 * @param otherValue The other value to compare with value (this is actually typed as &#42, but asdocs changes it to String for some reason).
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function different(value:*,otherValue:*,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(value===otherValue) throwError(message,exceptionType);
			return (value!==otherValue);
		}
		
		/**
		 * Assert if an Array is nil or empty.
		 * 
		 * @param array The array to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function nilOrEmpty(array:Array,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(!nil(array) && array.length>0) throwError(message,exceptionType);
			return (nil(array) || array.length==0);
		}
		
		/**
		 * Assert if an Array is not nil or empty.
		 * 
		 * @param array The array to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function notNilOrEmpty(array:Array, message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(nil(array) || array.length==0) throwError(message,exceptionType);
			return !(nil(array) || array.length==0);
		}
		
		/**
		 * Assert if an object is nil.
		 * 
		 * @param obj The object to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function nil(obj:*,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(!(obj === null || obj === undefined || !obj)) throwError(message, exceptionType);
			if(obj === null || obj === undefined || !obj) return true;
			return false;
		}
		
		/**
		 * Assert if an object is not nil.
		 * 
		 * @param object The object to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function notNil(object:*,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(nil(object)) throwError(message,exceptionType);
			return !(nil(object));
		}
		
		/**
		 * Assert if an object is compatible with another type.
		 * 
		 * @param obj The object to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function compatible(obj:*,type:Class,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(!(obj is type)) throwError(message,exceptionType);
			return (obj is type);
		}
		
		public static function allAreCompatible( arr:Array, type:Class, message:String=null, exceptionType:Class=null):Boolean
		{
			var bool:Boolean = false;
			
			for each(var obj:* in arr)
			{
				bool = compatible(obj, type, message, exceptionType);
			}
			
			return bool;
		}
		
		/**
		 * Assert if an object is not compatible with another type.
		 * 
		 * @param obj The object to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function notCompatible(obj:*, type:Class, message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if((compatible(obj,type))) throwError(message,exceptionType);
			return (!(compatible(obj,type)));
		}
		
		/**
		 * Assert that a string contains another string.
		 * 
		 * @param str The string to search in.
		 * @param pat The pattern that will be searched for in str.
		 */
		public static function contains(str:String,pat:String,message:String=null,exceptionType:Class=null):Boolean
		{
			if(message) if(nil(str) || smaller(str.indexOf(pat),0)) throwError(message,exceptionType);
			if(nil(str)) return false;
			return !smaller(str.indexOf(pat),0);
		}
		
		/**
		 * Assert a string as being empty (zero characters or all spaces).
		 * 
		 * @param str The string to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function emptyString(str:String,message:String=null,exceptionType:Class=null):Boolean
		{
			var r:RegExp=/^ {0,}$/i;
			if(message) if(!r.test(str)) throwError(message,exceptionType);
			return r.test(str);
		}
		
		/**
		 * Assert a string as being not empty (zero characters or all spaces).
		 * 
		 * @param str The string to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function notEmptyString(str:String,message:String=null,exceptionType:Class=null):Boolean
		{
			var r:RegExp=/^ {0,}$/i;
			if(message) if(r.test(str)) throwError(message,exceptionType);
			return !r.test(str);
		}
		
		/**
		 * Assert that a string has all number characters.
		 * 
		 * @param str The string to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function numberString(str:String,message:String=null,exceptionType:Class=null):Boolean
		{
			var regx:RegExp=/^[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?$/;
			if(message) if(nil(str) || (!regx.test(str))) throwError(message,exceptionType);
			if(nil(str)) return false;
			return regx.test(str);
		}
		
		/**
		 * Assert that a string does not have all number characters.
		 * 
		 * @param str The string to evaluate.
		 * @param message A message to throw if the assertion evaluates to false.
		 * @param exceptionType The exceptionType to throw if an exception is being thrown.
		 */
		public static function notNumberString(str:String,message:String=null,exceptionType:Class=null):Boolean
		{
			var regx:RegExp=/^[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?$/;
			if(message) if(notNil(str) && (regx.test(str))) throwError(message,exceptionType);
			if(nil(str)) return true;
			return !regx.test(str);
		}
		
		public static function classImplements(clazz:Class, implementor:Class, message:String=null, exceptionType:Class=null):Boolean
		{
			//TODO
			return false;
		}
	}
}