/**
 * IVisibleObject - written by Dylan Engelman a.k.a LordOfDuct
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
 * This interface is for defining a "view" property on an object. This allows the object to be used 
 * in conjunction with many display managing code supplied in the LoDGameFramework. If the object 
 * implementing the IVisibleObject interface is itself a DisplayObject just return 'this', and don't 
 * allow the property to be set. If it isn't and you would like to be able to attach DisplayObjects 
 * to it, then create a private var for storing and referencing this instance.
 * 
 * examples:
 * 
 * extending a DisplayObject
 * 
public class MyVisibleObject extends Sprite implements IVisibleObject
{
	public function MyVisibleObject()
	{
		
	}
	
	public function get view():DisplayObject { return this; }
	public function set view(value:DisplayObject):void { //do nothing }
}
 * 
 * not extending a DisplayObject
 * 
public class MyVisibleObject implements IVisibleObject
{
	private var _view:DisplayObject;
	
	public function MyVisibleObject()
	{
		
	}
	
	public function get view():DisplayObject { return _view; }
	public function set view(value:DisplayObject):void { _view = value; }
}
 */
package com.lordofduct.util
{
	import flash.display.DisplayObject;
	
	public interface IVisibleObject
	{
		function get view():DisplayObject
		function set view(value:DisplayObject):void
	}
}