package com.lordofduct.geom
{
	import com.lordofduct.util.LoDMath;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class LineSegment implements IGeometricShape
	{
		private var _st:Vector2;
		private var _en:Vector2;
		private var _rect:Rectangle;
		private var _dirty:Boolean = false;
		
		public function LineSegment(start:*, end:*)
		{
			_st = Vector2.copy(start);
			_en = Vector2.copy(end);
		}

/**
 * Properties
 */
		public function get start():Vector2 { return _st; }
		public function set start(value:Vector2):void { _st = (value) ? value : new Vector2(); }
		
		public function get end():Vector2 { return _en; }
		public function set end(value:Vector2):void { _en = (value) ? value : new Vector2(); }
	/**
	 * IGeometricShape Interface
	 */
		public function get numAxes():int
		{
			return 2;
		}
		
/**
 * Methods
 */
		public function getBoundingRect(mat:Matrix=null):Rectangle
		{
			var v1:Vector2 = (mat) ? Vector2.transformByMatrix(_st, mat) : _st;
			var v2:Vector2 = (mat) ? Vector2.transformByMatrix(_en, mat) : _en;
			
			var lft:Number = Math.min(v1.x, v2.x);
			var rght:Number = Math.max(v1.x, v2.x);
			var top:Number = Math.min(v1.y, v2.y);
			var bot:Number = Math.max(v2.x, v2.y);
			
			return new Rectangle(lft, top, rght - lft, bot - top);
		}
		
		public function getSimpleCenter(mat:Matrix=null):Vector2
		{
			var v1:Vector2 = (mat) ? Vector2.transformByMatrix(_st, mat) : _st;
			var v2:Vector2 = (mat) ? Vector2.transformByMatrix(_en, mat) : _en;
			
			return Vector2.lerp( v1, v2, 0.5 );
		}
		
		public function getAxis(index:int, mat:Matrix=null):Vector2
		{
			var axis:Vector2 = Vector2.subtract(_en, _st);
			if(mat) axis.rotateByMatrix(mat);
			axis.normalize();
			if(index > 0)
			{
				axis.normal();
				axis.negate();
			}
			return axis;
		}
		
		public function getAxes(mat:Matrix=null):Array
		{
			var axis:Vector2 = Vector2.subtract(_en, _st);
			if(mat) axis.rotateByMatrix(mat);
			axis.normalize();
			var v2:Vector2 = axis.clone();
			v2.negate();
			return [axis, v2];
		}
		
		public function getAxisNorm(index:int, mat:Matrix=null):Vector2
		{
			var axis:Vector2 = Vector2.subtract(_en, _st);
			axis.setTo(-axis.y, axis.x);
			if(mat) axis.rotateByMatrix(mat);
			axis.normalize();
			if(index < 1) axis.normal();
			return axis;
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{
			var axis:Vector2 = Vector2.subtract(_en, _st);
			axis.setTo(-axis.y, axis.x);
			if(mat) axis.rotateByMatrix(mat);
			axis.normalize();
			return [Vector2.normal(axis), axis];
		}
		
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{
			var v1:Vector2 = (mat) ? Vector2.transformByMatrix(_st, mat) : _st;
			var v2:Vector2 = (mat) ? Vector2.transformByMatrix(_en, mat) : _en;
			
			axis = Vector2.normalize(axis);
			var min:Number = v1.dot(axis);
			var max:Number = v2.dot(axis);
			return new Interval(min, max, axis);
		}
		
		public function findExtremitiesOver(axis:Vector2, mat:Matrix=null):Array
		{
			var v1:Vector2 = (mat) ? Vector2.transformByMatrix(_st, mat) : _st.clone();
			var v2:Vector2 = (mat) ? Vector2.transformByMatrix(_en, mat) : _en.clone();
			
			var d1:Number = v1.dot(axis);
			var d2:Number = v2.dot(axis);
			
			if(Math.abs(d1 - d2) < LoDMath.SHORT_EPSILON) return [ v1, v2 ];
			if(d1 < d2) return [v1];
			
			return [v2];
		}
		
		public function drawToGraphics(gr:Graphics, mat:Matrix=null):void
		{
			var v1:Vector2 = (mat) ? Vector2.transformByMatrix(_st, mat) : _st;
			var v2:Vector2 = (mat) ? Vector2.transformByMatrix(_en, mat) : _en;
			
			gr.moveTo(v1.x, v1.y);
			gr.lineTo(v2.x, v2.y);
		}
		
	}
}