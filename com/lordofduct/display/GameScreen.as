package com.lordofduct.display
{
	import com.lordofduct.util.LoDMath;
	
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class GameScreen extends LayerContainer
	{
		private var _camera:GameCamera;
		private var _renderRect:Rectangle;
		private var _camBounds:Rectangle;
		
		private var _mask:Shape;
		
		/**
		 * Constructor for GameScreen
		 * 
		 * @param camera - the default GameCamera for this GameScreen
		 * @param rect - the renderRect to use when rendering this GameScreen
		 */
		public function GameScreen( camera:GameCamera, rect:Rectangle=null ):void
		{
			_camera = camera;
			_mask = new Shape();
			//this.setInternalMask(_mask);
			this.renderRect = (rect) ? rect : new Rectangle( 0, 0, 500, 500 );
			this.setGameScreen( this );
		}
		
		/**
		 * The default GameCamera utilized by this GameScreen.
		 */
		public function get camera():GameCamera { return _camera; }
		public function set camera( value:GameCamera ):void { _camera = value; }
		
		/**
		 * A rectangle describing in which area relative to this to show itself
		 * 
		 * The camera is centered around this rectangle, and the GameScreen is masked by a Shape defined by this rectangle
		 */
		public function get renderRect():Rectangle { return _renderRect; }
		public function set renderRect( value:Rectangle ):void { if (value != null) _renderRect = value; updateMask(); }
		
		public function get cameraBoundary():Rectangle { return _camBounds; }
		public function set cameraBoundary(value:Rectangle):void { _camBounds = value; }
		
		override public function render(mat:Matrix=null):void
		{
			//first get matrix to use
			if (!mat)
			{
				//if not matrix param grab rendering matrix from camera
				mat = (_camera) ? _camera.getRenderingMatrix() : new Matrix();
			} else {
				//otherwise just use a clone of the supplied matrix
				mat = mat.clone();
			}
			
			mat.tx -= _renderRect.x - _renderRect.width / 2;
			mat.ty -= _renderRect.y - _renderRect.height / 2;
			
			//if _camBounds, restrain matrix
			if(_camBounds)
			{
				var m2:Matrix = mat.clone();
				m2.invert();
				var rect:Rectangle = LoDMath.transformRectByMatrix( _renderRect, m2 );
				
				var hmax:Number = _camBounds.right - Math.abs( rect.right - m2.tx );
				var hmin:Number = _camBounds.left + Math.abs( rect.left - m2.tx );
				var vmax:Number = _camBounds.bottom - Math.abs( rect.bottom - m2.ty );
				var vmin:Number = _camBounds.top + Math.abs( rect.top - m2.ty );
				
				m2.tx = LoDMath.clamp( m2.tx, hmax, hmin );
				m2.ty = LoDMath.clamp( m2.ty, vmax, vmin );
				
				m2.invert();
				mat = m2;
			}
			
			super.render(mat);
		}
		
		private function updateMask():void
		{
			_mask.graphics.clear();
			_mask.graphics.beginFill(0);
			_mask.graphics.drawRect(_renderRect.x, _renderRect.y,_renderRect.width, _renderRect.height);
			_mask.graphics.endFill();
			
			_mask.x = _mask.y = 0;
		}
	}
}