package com.lordofduct.geom
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class PointList
	{
		protected var _vX:Array = new Array();
		protected var _vY:Array = new Array();
		
		public function PointList()
		{
			
		}
		
		public function get numVerts():int { return _vX.length; }
		
/**
 * Methods
 */	
		public function getVert( index:uint ):Vector2
		{
			return (index < this.numVerts) ? new Vector2( _vX[index], _vY[index] ) : null;
		}
		
		public function getVertList( mat:Matrix=null ):Array
		{
			var arr:Array = new Array();
			while(arr.length < _vX.length)
			{
				var v:Vector2 = new Vector2( _vX[arr.length], _vY[arr.length] );
				if(mat) v.transformByMatrix(mat);
				arr.push( v );
			}
			return arr;
		}
		
		public function getVertX( index:uint ):Number
		{
			return _vX[index];
		}
		
		public function getVertY( index:uint ):Number
		{
			return _vY[index];
		}
		
		public function pushVert(pnt:*, ...rest ):void
		{
			Assertions.isTrue( (pnt is Point || pnt is Point2D), "com.lordofduct.geom::Polygon2D - can not access object that is not a Point or Point2D." );
			
			_vX.push( pnt.x );
			_vY.push( pnt.y );
			
			for each( pnt in rest )
			{
				this.pushVert( pnt );
			}
		}
		
		public function pushVertPair(ix:Number, iy:Number):void
		{
			_vX.push( ix );
			_vY.push( iy );
		}
		
		public function popVert():Vector2
		{
			return (this.numVerts) ? new Vector2( _vX.pop(), _vY.pop() ) : null;
		}
		
		public function setVert( index:uint, pnt:* ):void
		{
			Assertions.isTrue( (pnt is Point || pnt is Point2D), "com.lordofduct.geom::Polygon2D - can not access object that is not a Point or Point2D." );
			
			_vX[index] = pnt.x;
			_vY[index] = pnt.y;
		}
		
		public function setVertPair( index:uint, ix:Number, iy:Number ):void
		{
			_vX[index] = ix;
			_vY[index] = iy;
		}
		
		public function setVertX( index:uint, value:Number ):void
		{
			_vX[index] = value;
		}
		
		public function setVertY( index:uint, value:Number ):void
		{
			_vY[index] = value;
		}
		
		/**
		 * return the length of some side at index
		 * 
		 * leg index is equivalent to start vertex
		 * 
		 * 0 = leg 0->1
		 * 1 = leg 1->2
		 * 2 = leg 2->0
		 * ...
		 * maxVerts-1 = leg maxVerts-1 -> 0
		 */
		public function computeSideLength( index:uint, mat:Matrix=null ):Number
		{
			index = LoDMath.wrap( index, this.numVerts );
			
			//get end points of leg
			var i1:int = index;
			var i2:int = (index + 1) % _vX.length;
			var ix:Number = _vX[i2] - _vX[i1];
			var iy:Number = _vY[i2] - _vY[i1];
			if(mat)
			{
				var tmp:Number = ix * mat.a + iy * mat.c;
				iy = ix + mat.b + iy * mat.d;
				ix = tmp;
			}
			//compute length between
			return Math.sqrt( ix * ix + iy * iy );
		}
	}
}