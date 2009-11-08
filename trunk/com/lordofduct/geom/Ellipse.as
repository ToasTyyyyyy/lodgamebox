package com.lordofduct.geom
{
	import com.lordofduct.util.LoDMatrixTransformer;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Ellipse implements IGeometricShape
	{
		private var _cX:Number;
		private var _cY:Number;
		private var _rh:Number;
		private var _rv:Number;
		private var _rot:Number;
		
		public function Ellipse( cX:Number, cY:Number, hor:Number, ver:Number, rot:Number=0 )
		{
			_cX = cX;
			_cY = cY;
			_rh = hor;
			_rv = ver;
			_rot = rot;
		}

/**
 * Properties
 */
		public function get centerX():Number { return _cX; }
		public function set centerX(value:Number):void { _cX = value; }
		
		public function get centerY():Number { return _cY; }
		public function set centerY(value:Number):void { _cY = value; }
		
		public function get horizontal():Number { return _rh; }
		public function set horizontal( value:Number ):void { _rh = Math.abs(value); }
		
		public function get vertical():Number { return _rv; }
		public function set vertical( value:Number ):void { _rv = Math.abs(value); }
		
		public function get rotation():Number { return _rot; }
		public function set rotation(value:Number):void { _rot = value; }
	/**
	 * IGeometricShape interface
	 */
		public function get numAxes():int
		{
			return 2;
		}
		
		public function getBoundingRect(mat:Matrix=null):Rectangle
		{
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			if(mat) m.concat(mat);
			
			var hor:Interval = this.projectOntoAxis( Vector2.UnitX, m );
			var ver:Interval = this.projectOntoAxis( Vector2.UnitY, m );
			
			return new Rectangle( hor.min, ver.min, hor.intervalLength, ver.intervalLength );
		}
		
		public function getSimpleCenter(mat:Matrix=null):Vector2
		{
			//no need to rotate mat by _rot, the center is the rotation origin
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
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			if(mat) m.concat(mat);
			
			index %= this.numAxes;
			var v:Vector2;
			if( index )
			{
				v = new Vector2( m.c, m.d );
			} else {
				v = new Vector2( m.a, m.b );
			}
			
			v.normalize();
			return v;
		}
		
		public function getAxes(mat:Matrix=null):Array
		{
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			if(mat) m.concat(mat);
			
			var arr:Array = new Array();
			
			var v:Vector2 = new Vector2( m.a, m.b );
			v.normalize();
			arr.push(v);
			v = new Vector2( m.c, m.d );
			v.normalize();
			arr.push(v);
			
			return arr;
		}
		
		public function getAxisNorm(index:int, mat:Matrix=null):Vector2
		{
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			if(mat) m.concat(mat);
			
			index %= this.numAxes;
			var v:Vector2;
			if( index )
			{
				v = new Vector2( -m.c, -m.d );
			} else {
				v = new Vector2( m.a, m.b );
			}
			
			return Vector2.normal(v);
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			if(mat) m.concat(mat);
			
			var arr:Array = new Array();
			
			var v:Vector2 = new Vector2( m.a, m.b );
			arr.push(Vector2.normal(v));
			v.setTo( m.c, m.d );
			arr.push(Vector2.normal(v));
			
			return arr;
		}
		
		/**
		 * Project the ellipse onto any axis.
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
		 * brings the axis into local space (inverse mat)
		 * then solves at which angle a vector normal to the tangent for that angle 
		 * is parallel to the axis supplied
		 * 
		 * eq: angle(t) = atan( (axis.y * vRadius) / (axis.x * hRadius) )
		 * from:
		 * f(t) = <hcost, vsint>
		 * f'(t) = <-hsint, vcost>
		 * N of f'(t) = <vcost,hsint>
		 * 
		 * if two vectors are parallel, their angle off the x-axis are the same
		 * angle = atan( y / x )
		 * 
		 * so:
		 * if axis = <i, j>
		 * 
		 * atan( hsin(t) / vcos(t) ) = atan( j / i )
		 * - solve tan each side
		 * hsin(t) / vcost = j / i
		 * - tan(x) = sin(x) / cos(x) : defined
		 * htan(t)/v = j / i
		 * - muliply recip
		 * tan(t) = jv / ih
		 * - use arctan to get t alone
		 * t = atan( jv / ih )
		 * 
		 * t AND t + PI will give us the widest points of the ellipse along this local axis.
		 */
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			if(mat) m.concat(mat);
			
			axis = Vector2.normalize(axis);
			var v:Vector2 = axis.clone();
			
			var m2:Matrix = m.clone();
			m2.invert();
			v.rotateByMatrix( m2 );
			
			var t:Number = Math.atan( (v.y * _rv) / (v.x * _rh) );
			v.setTo( _rh * Math.cos(t) + _cX, _rv * Math.sin(t) + _cY );
			v.transformByMatrix(m);
			var max:Number = v.dot(axis);
			
			t += Math.PI;
			v.setTo( _rh * Math.cos(t) + _cX, _rv * Math.sin(t) + _cY )
			v.transformByMatrix(m);
			var min:Number = v.dot(axis);
			
			return new Interval(min, max, axis);
		}
		
		public function findExtremitiesOver(axis:Vector2, mat:Matrix=null):Array
		{
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			if(mat) m.concat(mat);
			
			var v:Vector2 = axis.clone();
			
			var m2:Matrix = m.clone();
			m2.invert();
			v.rotateByMatrix( m2 );
			v.normalize();
			
			var t:Number = Math.atan2( (v.y * _rv), (v.x * _rh) );
			t += Math.PI;
			v.setTo( _rh * Math.cos(t) + _cX, _rv * Math.sin(t) + _cY );
			v.transformByMatrix(m);
			
			return [ v ];
		}
		
	/**
	 * Bullshit Methods
	 */
		public function drawToGraphics( gr:Graphics, mat:Matrix=null ):void
		{	
			var cen:Vector2 = this.getSimpleCenter(mat);
			var m:Matrix = LoDMatrixTransformer.createRotationMatrix(_rot);
			//if(mat) m.concat(mat);
			
			var i:int = 40, ang:Number, pnt:Vector2 = new Vector2();
			
			pnt.setTo(_rh, 0);
			pnt.rotateByMatrix(m);
			gr.moveTo(pnt.x + cen.x, pnt.y + cen.y);
			
			while(--i > 0)
			{
				ang = 2 * Math.PI * i / 40;
				pnt.x = _rh * Math.cos(ang);
				pnt.y = _rv * Math.sin(ang);
				
				pnt.rotateByMatrix(m);
				gr.lineTo(pnt.x + cen.x, pnt.y + cen.y);
			}
			
			pnt.setTo(_rh, 0);
			pnt.rotateByMatrix(m);
			gr.lineTo(pnt.x + cen.x, pnt.y + cen.y);
		}
		
	}
}