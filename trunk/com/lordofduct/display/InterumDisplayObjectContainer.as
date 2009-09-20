package com.lordofduct.display
{
	import com.lordofduct.util.LoDMatrixTransformer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class InterumDisplayObjectContainer extends Sprite
	{
		public var inheritTranslationX:Boolean = false;
		public var inheritTranslationY:Boolean = false;
		public var inheritRotation:Boolean = false;
		public var inheritSkewX:Boolean = false;
		public var inheritSkewY:Boolean = false;
		public var inheritScaleX:Boolean = false;
		public var inheritScaleY:Boolean = false;
		
		public function InterumDisplayObjectContainer()
		{
			this.addEventListener( Event.RENDER, updateTransform, false, 0, true );
		}
		
		public function get inheritTranslation():Boolean { return this.inheritTranslationX && this.inheritTranslationY; }
		public function set inheritTranslation(value:Boolean):void
		{
			this.inheritTranslationX = this.inheritTranslationY = value;
		}
		
		private function updateTransform(e:Event):void
		{
			if(!this.parent) return;
			
			var m:Matrix = parent.transform.matrix;
			
			if(this.inheritTranslationX)
			{
				m.tx = 0;
			}
			if(this.inheritTranslationY)
			{
				m.ty = 0;
			}
			if(this.inheritRotation)
			{
				LoDMatrixTransformer.setRotation(m, 0);
			}
			if(this.inheritScaleX)
			{
				LoDMatrixTransformer.setScaleX(m,1);
			}
			if(this.inheritScaleY)
			{
				LoDMatrixTransformer.setScaleY(m,1);
			}
			if(this.inheritSkewX)
			{
				LoDMatrixTransformer.setSkewX(m,0);
			}
			if(this.inheritSkewY)
			{
				LoDMatrixTransformer.setSkewY(m,0);
			}
			
			m.invert();
			this.transform.matrix = m;
		}
	}
}