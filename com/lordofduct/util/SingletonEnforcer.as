/**
 * SingletonEnforcer - written by Dylan Engelman a.k.a LordOfDuct
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
 * 
 * 
 * The SingletonEnforcer class is a helper class to enforce singletons. Design of 
 * this class inspired by the Guttershark library method of enforcing Singletons.
 * 
 * example of singleton:
 * public class MySingleton
 * {
 *     private static var _inst:MySingleton;
 *     
 *     public static function get instance():MySingleton
 *     {
 *         if(!_inst) _inst=SingletonEnforcer.gi(MySingleton);
 *         return _inst;
 *     }
 * 
 *     public function MySingleton()
 *     {
 *         Singleton.assertSingle(MySingleton);
 *     }
 * }
 * 
 * TODO - show cancel parent class example
 */
package com.lordofduct.util
{
	import flash.utils.Dictionary;
	
	public class SingletonEnforcer
	{
		public function SingletonEnforcer()
		{
			Assertions.throwError("com.lorofduct.util::SingletonEnforcer - can not instantiate static member class.", Error);
		}
		
/**
 * Static interface
 */
		/**
		 * Keeps track of the instances available.
		 */
		private static var _insts:Dictionary;
		
		/**
		 * Get an instance of a class, and cancel any parent classes.
		 * 
		 * @param clazz - The class of the instance you're after.
		 * @param args - An array of Classes to cancel, so they cannot be instantiated again.
		 * This is specifically for when you extend a singleton, you need to make sure you pass all of it's
		 * super classes that you don't want instantiated ever... this isn't necessary if the extending class is unique.
		 */
		public static function gi(clazz:Class,...args:Array):*
		{
			var inst:*;
			if(!_insts) _insts=new Dictionary();
			if(_insts[clazz] && _insts[clazz] != -1) inst=_insts[clazz];
			if(!inst)
			{
				inst=new clazz();
				_insts[clazz]=inst;
			}
			if(args && args.length) for each(var cl:Class in args){_insts[cl]=-1;}
			return inst;
		}
		
		/**
		 * Assert that there is only one instance of a class.
		 * 
		 * @param clazz - The Class to assert as being the only instance.
		 */
		public static function assertSingle(clazz:Class):void
		{
			if(_insts[clazz]) throw new Error("Error creating class, {"+clazz+"}. It's a singleton and cannot be instantiated more than once.");
		}
	}
}