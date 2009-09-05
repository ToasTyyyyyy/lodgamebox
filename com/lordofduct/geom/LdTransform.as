/**
 * LdTransform - written by Dylan Engelman a.k.a LordOfDuct
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
package com.lordofduct.geom
{
	import com.lordofduct.util.IClonable;
	import com.lordofduct.util.ITransformable;
	import com.lordofduct.util.LoDMatrixTransformer;
	
	import flash.geom.Matrix;
	import flash.geom.Transform;
	
	public class LdTransform implements IClonable, ITransformable
	{
		protected var _trans:Matrix;
		
		public function LdTransform( mat:Matrix=null )
		{
			if( mat ) _trans = mat.clone();
			else _trans = new Matrix();
		}
		
/**
 * Properties
 */
	/**
	 * Public Properties
	 */
		public function get matrix():Matrix { return _trans.clone(); }
		public function set matrix( value:Matrix ):void
		{
			_trans = value.clone();
			
		}
		
		public function get x():Number { return _trans.tx; }
		public function set x( value:Number ):void
		{
			_trans.tx = value;
			
		}
		
		public function get y():Number { return _trans.ty; }
		public function set y( value:Number ):void
		{
			_trans.ty = value;
			
		}
		
		public function get rotation():Number { return LoDMatrixTransformer.getRotation( _trans ); }
		public function set rotation( value:Number ):void
		{
			LoDMatrixTransformer.setRotation( _trans, value );
			
		}
		
		public function get scaleX():Number { return LoDMatrixTransformer.getScaleX(_trans); }
		public function set scaleX(value:Number):void
		{
			LoDMatrixTransformer.setScaleX(_trans,value);
			
		}
		
		public function get scaleY():Number { return LoDMatrixTransformer.getScaleY(_trans); }
		public function set scaleY(value:Number):void
		{
			LoDMatrixTransformer.setScaleY(_trans,value);
			
		}
		
		public function get skewX():Number { return LoDMatrixTransformer.getSkewX( _trans ); }
		public function set skewX( value:Number ):void
		{
			LoDMatrixTransformer.setSkewX( _trans, value );
		}
		
		public function get skewY():Number { return LoDMatrixTransformer.getSkewY( _trans ); }
		public function set skewY( value:Number ):void
		{
			LoDMatrixTransformer.setSkewY( _trans, value );
		}
/**
 * Methods
 */
	/**
	 * Public Methods
	 */
		public function rotate(value:Number):void
		{
			LoDMatrixTransformer.rotateAroundExternalPoint( _trans, _trans.tx, _trans.ty, value );
		}
		
		public function scale(sx:Number, sy:Number):void
		{
			_trans.scale(sx,sy);
		}
		
		public function setScale(sx:Number,sy:Number):void
		{
			LoDMatrixTransformer.setScaleX(_trans,sx);
			LoDMatrixTransformer.setScaleY(_trans,sy);
		}
		
		public function syncFormalTransform( trans:Transform ):void
		{
			if(trans) trans.matrix = _trans;
		}
	/**
	 * IClonable Interface
	 */
		public function copy( obj:* ):void
		{
			if(obj is LdTransform || obj is Transform) _trans = obj.matrix;
		}
		
		public function clone():*
		{
			return new LdTransform( _trans );
		}
	}
}