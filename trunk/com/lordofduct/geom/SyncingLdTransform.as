/**
 * NAME_OF_CLASS - written by Dylan Engelman a.k.a LordOfDuct
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
 * This class can be used to in conjunction with a SyncingTransform to update the transform matrix 
 * of a DisplayObject automatically. 
 * 
 * Example:
 * 
 * var obj:DisplayObject = new Sprite();
 * var ldTrans:SyncingLdTransform = new SyncingLdTransform();
 * obj.transform = SyncingTransform.createSyncingTransforms( obj, obj.trans, ldTrans );
 * 
 * ldTrans.x = 5;//update the ldTransform
 * trace(obj.x);//traces 5, because the ldTrans and Transform are synced.
 */
package com.lordofduct.geom
{
	import com.lordofduct.util.LoDMatrixTransformer;
	
	import flash.geom.Matrix;
	import flash.geom.Transform;

	public class SyncingLdTransform extends LdTransform
	{
		private var _sync:SyncingTransform;
		
		public function SyncingLdTransform(mat:Matrix=null, sync:SyncingTransform=null)
		{
			super(mat);
			
			_sync = sync;
			if(_sync) _sync.setSyncMatrix(_trans);
		}
/**
 * Properties
 */
	/**
	 * Public Properties
	 */
		override public function set matrix( value:Matrix ):void
		{
			_trans = value.clone();
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function set x( value:Number ):void
		{
			_trans.tx = value;
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function set y( value:Number ):void
		{
			_trans.ty = value;
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function set rotation( value:Number ):void
		{
			LoDMatrixTransformer.setRotation( _trans, value );
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function set scaleX(value:Number):void
		{
			LoDMatrixTransformer.setScaleX(_trans,value);
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function set scaleY(value:Number):void
		{
			LoDMatrixTransformer.setScaleY(_trans,value);
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function set skewX( value:Number ):void
		{
			LoDMatrixTransformer.setSkewX( _trans, value );
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function set skewY( value:Number ):void
		{
			LoDMatrixTransformer.setSkewY( _trans, value );
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		public function get linkedTransform():SyncingTransform { return _sync; }
		public function set linkedTransform(value:SyncingTransform):void { _sync = value; if(_sync) _sync.setSyncMatrix(_trans); }
/**
 * Methods
 */
	/**
	 * Public Methods
	 */
		override public function rotate(value:Number):void
		{
			LoDMatrixTransformer.rotateAroundExternalPoint( _trans, _trans.tx, _trans.ty, value );
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function scale(sx:Number, sy:Number):void
		{
			_trans.scale(sx,sy);
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
		override public function setScale(sx:Number,sy:Number):void
		{
			LoDMatrixTransformer.setScaleX(_trans,sx);
			LoDMatrixTransformer.setScaleY(_trans,sy);
			if(_sync) _sync.setSyncMatrix(_trans);
		}
		
	/**
	 * Internal Methods
	 */
		internal function setSyncMatrix(value:Matrix):void
		{
			_trans = value.clone();
		}
	}
}