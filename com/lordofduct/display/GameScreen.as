package com.lordofduct.display
{
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class GameScreen extends LayerContainer
	{
		private var _camera:GameCamera;
		private var _renderRect:Rectangle;
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
			this.mask = _mask;
			this.addChild(_mask);
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
		
		override public function render(mat:Matrix=null):void
		{
			if (!mat)
			{
				//if not matrix param grab rendering matrix from camera
				mat = (_camera) ? _camera.getRenderingMatrix() : new Matrix();
				mat.tx -= _renderRect.x - _renderRect.width / 2;
				mat.ty -= _renderRect.y - _renderRect.height / 2;
			} else {
				//otherwise just use a clone of the supplied matrix
				mat = mat.clone();
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