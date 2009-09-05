/**
 * ITransformable - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Interface written and devised for the LoDGameLibrary. The use of this code 
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
 * This defines an object to be transformable. It merely defines access to different transformative 
 * properties. This interface is identical to the DisplayObject transformative properties. This is 
 * so that you can implement this interface on a DisplayObject with ease OR you can define it to 
 * other objects that don't extend DisplayObject.
 * 
 * In the case that you must define the interface yourself. It is advised to utilize the LdTransform object 
 * and just interpret the already present methods through it. LdTransform prefers rotation in radians.
 */
package com.lordofduct.util
{
	import flash.geom.Matrix;
	
	public interface ITransformable
	{
		function get x():Number
		function set x(value:Number):void
		
		function get y():Number
		function set y(value:Number):void
		
		function get rotation():Number
		function set rotation( value:Number ):void
		
		function get scaleX():Number
		function set scaleX(value:Number):void
		
		function get scaleY():Number
		function set scaleY(value:Number):void
	}
}