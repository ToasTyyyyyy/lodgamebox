package com.lordofduct.geom
{
	import com.lordofduct.util.LoDMatrixTransformer;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Circle implements IGeometricShape
	{
		private var _cX:Number;
		private var _cY:Number;
		private var _radius:Number;
		
		public function Circle( cX:Number, cY:Number, rad:Number )
		{
			_cX = cX;
			_cY = cY;
			_radius = rad;
		}
		
/**
 * Properties
 */
		public function get centerX():Number { return _cX; }
		public function set centerX(value:Number):void { _cX = value; }
		
		public function get centerY():Number { return _cY; }
		public function set centerY(value:Number):void { _cY = value; }
		
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void { _radius = value; }
	/**
	 * IGeometricShape interface
	 */
		public function get numAxes():int
		{
			return 2;
		}
		
		/**
		 * Gets the bounding rect for the circle
		 * 
		 * @param mat: an optional matrix to transform the circle by before computing the 
		 * bounding rect. If the matrix is skewed or scaled at all, then a circle that circumscribes 
		 * the new shape is what the rect will be computed from.
		 * 
		 * For instance, if the matrix were to turn the circle into a oval, a circle circumsribing that 
		 * oval will then have a rect drawn around it.
		 * 
		 * Thusly, any bounding rect will ALWAYS be a square.
		 */
		public function getBoundingRect(mat:Matrix=null):Rectangle
		{
			if(mat)
			{
				var sc:Number = Math.max( LoDMatrixTransformer.getScaleX(mat), LoDMatrixTransformer.getScaleY(mat) );
				var r:Number = _radius * sc;
				var tx:Number = mat.tx + _cX - r;
				var ty:Number = mat.ty + _cY - r;
				var l:Number = r * 2;
				return new Rectangle( tx, ty, l, l );
			}
			else return new Rectangle( _cX - _radius, _cY - _radius, _radius * 2, _radius * 2 );
		}
		
		public function getSimpleCenter(mat:Matrix=null):Vector2
		{
			var c:Vector2 = new Vector2(_cX, _cY);
			if(mat) c.transformByMatrix(mat);
			return c;
		}
		
/**
 * Methods
 */
	/**
	 * IGeometricShape interface
	 */
		public function getAxis(index:int, mat:Matrix=null):Vector2
		{
			if(!mat) mat = new Matrix();
			index %= this.numAxes;
			var v:Vector2;
			if( index )
			{
				v = new Vector2( mat.c, mat.d );
			} else {
				v = new Vector2( mat.a, mat.b );
			}
			
			v.normalize();
			return v;
		}
		
		public function getAxes(mat:Matrix=null):Array
		{
			if(!mat) mat = new Matrix();
			var arr:Array = new Array();
			
			var v:Vector2 = new Vector2( mat.a, mat.b );
			v.normalize();
			arr.push(v);
			v = new Vector2( mat.c, mat.d );
			v.normalize();
			arr.push(v);
			return arr;
		}
		
		public function getAxisNorm(index:int, mat:Matrix=null):Vector2
		{
			if(!mat) mat = new Matrix();
			index %= this.numAxes;
			var v:Vector2;
			if( index )
			{
				v = new Vector2( -mat.c, -mat.d );
			} else {
				v = new Vector2( mat.a, mat.b );
			}
			
			return Vector2.normal(v);
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{
			if(!mat) mat = new Matrix();
			var arr:Array = new Array();
			
			var v:Vector2 = new Vector2( mat.a, mat.b );
			arr.push(Vector2.normal(v));
			v.setTo( mat.c, mat.d );
			arr.push(Vector2.normal(v));
			return arr;
		}
		
		/**
		 * Project the circle onto any axis.
		 * 
		 * @param axis - Vector2 representing the axis to project on to
		 * 
		 * @param mat - optional Matrix to transform the ellipse by before projecting
		 * 
		 * @return - returns an Interval object representing the min and max positions on that axis.
		 * 
		 * 
		 * Detailed explanation:
		 * 
		 * TODO: we need to repair this to generalize it for all Matrices.
		 * 
		 * Unsure if we are going to allow all transformations of the matrix (like an ellipse) 
		 * or generalize the Matrix like we did with boundingRect. I want to go for the ladder, 
		 * but that restricts the Circle object. Though with the same respect, it will be much faster.
		 */
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{
			axis = Vector2.normalize(axis);
			var center:Vector2 = this.getSimpleCenter(mat);
			var cd:Number = center.dot(axis);
			
			if(mat)
			{
				var v1:Vector2 = new Vector2( axis.x * _radius, axis.y * _radius );
				var dot:Number = v1.dot(axis);
				return new Interval( cd - dot, cd + dot, axis );
				
			} else {
				return new Interval( cd - _radius, cd + _radius, axis );
			}
		}
		
		public function findExtremitiesOver(axis:Vector2, mat:Matrix=null):Array
		{
			axis = Vector2.normalize(axis);
			var center:Vector2 = this.getSimpleCenter(mat);
			var r:Number = _radius;
			if(mat) r *= LoDMatrixTransformer.getScaleX(mat);
			center.x -= axis.x * r;
			center.y -= axis.y * r;
			return [center];
		}
		
	/**
	 * Bullshit Methods
	 */
		public function drawToGraphics( gr:Graphics, mat:Matrix=null ):void
		{	
			var r:Number = _radius;
			var cen:Vector2 = this.getSimpleCenter(mat);
			
			if(mat)
			{
				var v1:Vector2 = new Vector2( r, 0 );
				v1.rotateByMatrix(mat);
				r = v1.length;
			}
			
			gr.drawCircle(cen.x, cen.y, r);
		}
		
	}
}