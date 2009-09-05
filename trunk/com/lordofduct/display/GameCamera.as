package com.lordofduct.display
{
	import com.lordofduct.geom.LdTransform;
	import com.lordofduct.util.ITransformable;
	
	import flash.geom.Matrix;
	
	public class GameCamera implements ITransformable
	{
		private var _trans:LdTransform = new LdTransform();
		
		public function GameCamera():void
		{
		}
		
/**
 * Public Properties
 */
		public function get ldTransform():LdTransform
		{
			return _trans;
		}
		
		public function set ldTransform(value:LdTransform):void
		{
			_trans = value;
		}
	/**
	 * ITransformable Interface
	 * 
	 * These Properties are just interpreters to pass through from LdTransform
	 */
		public function get x():Number { return _trans.x; }
		public function set x( value:Number ):void { _trans.x = value; }
		
		public function get y():Number { return _trans.y; }
		public function set y( value:Number ):void { _trans.y = value; }
		
		public function get rotation():Number { return _trans.rotation; }
		public function set rotation( value:Number ):void { _trans.rotation = value; }
		
		public function get scaleX():Number { return _trans.scaleX; }
		public function set scaleX(value:Number):void { _trans.scaleX = value; }
		
		public function get scaleY():Number { return _trans.scaleY; }
		public function set scaleY(value:Number):void { _trans.scaleY = value; }
		
		/**
		 * Zoom effects both scaleX and scaleY, when setting the zoom both scaleX and scaleY are set to 
		 * the given value. Where as when you retrieve the value it is the average of scaleX and scaleY. 
		 * In cases where you manually set the scale, the zoom represents the average between the two. Where 
		 * as if the scales were set via zoom, it returns a value equal to both of them.
		 */
		public function get zoom():Number
		{
			return (_trans.scaleX + _trans.scaleY) / 2;
		}
		public function set zoom( value:Number ):void
		{
			_trans.setScale(value,value);
		}
		
/**
 * Public Methods
 */
		
		/**
		 * Retrieve a Rendering Matrix. This is an inverted matrix that describes the position a DisplayObject 
		 * should be to give the illussion of the Camera being moved.
		 */
		public function getRenderingMatrix():Matrix
		{
			var m:Matrix = _trans.matrix;
			m.invert();
			
			return m;
		}
		
		public function renderGameScreen(layer:GameScreen):void
		{
			layer.render(this.getRenderingMatrix());
		}
	}
}