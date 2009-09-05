/**
 * SyncingTransform - written by Dylan Engelman a.k.a LordOfDuct
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
 * This class can be used to replace a DisplayObjects Transform object and have it update automatically 
 * with an LdTransform. You must use both a SyncingLdTransform in conjunction with a SyncingTransform. 
 */
package com.lordofduct.geom
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Transform;

	public class SyncingTransform extends Transform
	{
		private var _linkedTrans:SyncingLdTransform;
		
		public function SyncingTransform(displayObject:DisplayObject, ldTrans:SyncingLdTransform=null)
		{
			super(displayObject);
			
			_linkedTrans = ldTrans;
			if(_linkedTrans) _linkedTrans.setSyncMatrix(this.matrix);
		}
		
		public function get linkedTransform():SyncingLdTransform { return _linkedTrans; }
		public function set linkedTransform(value:SyncingLdTransform):void { _linkedTrans = value; }
		
		override public function set matrix(value:Matrix):void
		{
			super.matrix = value;
			if(_linkedTrans) _linkedTrans.setSyncMatrix(value);
		}
		
		internal function setSyncMatrix(value:Matrix):void
		{
			super.matrix = value;
		}
		
		
/**
 * STATIC FACTORY
 */
		static public function createSyncingTransforms( dis:DisplayObject, trans:Transform=null, ldTrans:SyncingLdTransform=null ):SyncingTransform
		{
			var strans:SyncingTransform = new SyncingTransform( dis, ldTrans );
			
			if(trans)
			{
				strans.matrix = trans.matrix;
				strans.colorTransform = trans.colorTransform;
			}
			
			if(ldTrans)
			{
				ldTrans.linkedTransform = strans;
			}
			
			return strans;
		}
	}
}