/**
 * ConventionalLayer - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * When rendered ConventionalLayers generally overwrite their transform matrix. So settling any 
 * translation via the normal DisplayObject interface is useless. Layers are intended to be 
 * assumed at a (0,0) position unless otherwise manipulated by the rendering matrix passed via 
 * the "render(...)" method.
 * 
 * If you'd like to manipulate general position before render that will be concatenated to the rendering 
 * matrix, then access the LdTransform object per described in the ITransformable interface.
 * 
 * All ConventionalLayers are intended for use with a GameScreen
 */
package com.lordofduct.display
{
	import com.lordofduct.util.LoDMath;
	
	import flash.geom.Matrix;

	public class LayerConventional extends LdTranSprite
	{
		private var _dpX:Number = 0;
		private var _dpY:Number = 0;
		private var _screen:GameScreen = null;
		
		public function LayerConventional()
		{
			super();
		}
		
		public function get gameScreen():GameScreen { return _screen; }
		
		/**
		 * sets an offset of how quickly the layer scrolls vertically or horizontally 
		 * when the layer is rendered.
		 * 
		 * value is between -1 and 1
		 * 
		 * larger value scroll more quickly then lower values
		 */
		public function get depthRatio():Number { return _dpX; }
		public function set depthRatio(value:Number):void { _dpX = _dpY = LoDMath.clamp( value, 1, -1 ); }
		
		public function get depthRatioX():Number { return _dpX; }
		public function set depthRatioX(value:Number):void { _dpX = LoDMath.clamp( value, 1, -1 ); }
		
		public function get depthRatioY():Number { return _dpY; }
		public function set depthRatioY(value:Number):void { _dpY = LoDMath.clamp( value, 1, -1 ); }
		
		/**
		 * Render this layer
		 * 
		 * when rendering, the matrix passed is concatenated to the LdTransform present. It is then set 
		 * to the flash transform object for proper display on screen. This is basically an access point 
		 * for rendering a layer via some GameCamera
		 */
		public function render(mat:Matrix=null):void
		{
			mat = (mat) ? mat.clone() : new Matrix();
			mat.tx *= 1 + this.depthRatioX;
			mat.ty *= 1 + this.depthRatioY;
			
			var m:Matrix = this.ldTransform.matrix;
			m.concat(mat);
			this.transform.matrix = m;
		}
		
/**
 * Internal Interface
 */
		internal function setGameScreen( screen:GameScreen ):void
		{
			_screen = screen;
		}
	}
}