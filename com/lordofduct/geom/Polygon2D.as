package com.lordofduct.geom
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Polygon2D extends PointList implements IGeometricShape
	{
		private var _maxVerts:int;
		
		private var _center:Vector2;
		private var _boundingRect:Rectangle;
		private var _axes:Array = new Array();
		private var _dirty:Boolean = true;
		
		public function Polygon2D( verts:int=-1 )
		{
			super();
			
			_maxVerts = verts;
		}
		
/**
 * Properties
 */
		public function get maxVerts():int { return _maxVerts; }
		
	/**
	 * IGeometricShape interface
	 */
		public function get numAxes():int
		{
			return _vX.length;
		}
		
		public function getBoundingRect(mat:Matrix=null):Rectangle
		{
			if(!this.numVerts) return new Rectangle();
			
			var xaxis:Interval = this.projectOntoAxis(Vector2.UnitX, mat);
			var yaxis:Interval = this.projectOntoAxis(Vector2.UnitY, mat);
			
			return new Rectangle(xaxis.min, yaxis.min, xaxis.intervalLength, yaxis.intervalLength);
		}
		
		public function getSimpleCenter(mat:Matrix=null):Vector2
		{
			if(_dirty) this.cleanPolygon();
			
			if(mat) return Vector2.transformByMatrix(_center, mat);
			else return _center.clone();
		}
/**
 * Methods
 */	
		override public function pushVert(pnt:*, ...rest ):void
		{
			Assertions.smallerOrEqual( this.numVerts, uint(_maxVerts), "com.lordofduct.geom::Polygon2D - can not add more verts then is allowed by maxVerts." );
			
			super.pushVert(pnt);
			_dirty = true;
			
			for each( pnt in rest )
			{
				super.pushVert( pnt );
			}
		}
		
		override public function pushVertPair(ix:Number, iy:Number):void
		{
			Assertions.smallerOrEqual( this.numVerts, uint(_maxVerts), "com.lordofduct.geom::Polygon2D - can not add more verts then is allowed by maxVerts." );
			
			super.pushVertPair(ix, iy);
			_dirty = true;
		}
		
		override public function setVert( index:uint, pnt:* ):void
		{
			Assertions.smaller( index, uint(_maxVerts), "com.lordofduct.geom::Polygon2D - can not access vert out of max vert range." );
			
			super.setVert( index, pnt );
			_dirty = true;
		}
		
		override public function setVertPair( index:uint, ix:Number, iy:Number ):void
		{
			Assertions.smaller( index, uint(_maxVerts), "com.lordofduct.geom::Polygon2D - can not access vert out of max vert range." );
			
			super.setVertPair( index, ix, iy );
			_dirty = true;
		}
		
		override public function setVertX( index:uint, value:Number ):void
		{
			Assertions.smaller( index, uint(_maxVerts), "com.lordofduct.geom::Polygon2D - can not access vert out of max vert range." );
			
			super.setVertX( index, value );
			_dirty = true;
		}
		
		override public function setVertY( index:uint, value:Number ):void
		{
			Assertions.smaller( index, uint(_maxVerts), "com.lordofduct.geom::Polygon2D - can not access vert out of max vert range." );
			
			super.setVertY( index, value );
			_dirty = true;
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
			index = LoDMath.wrap( index, this.numAxes );
			Assertions.smaller( index, uint(_maxVerts), "com.lordofduct.geom::Polygon2D - can not access vert out of max vert range." );
			
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
		
	/**
	 * IGeometricShape interface
	 */
		public function getAxis(index:int, mat:Matrix=null):Vector2
		{
			index = LoDMath.wrap( index, this.numAxes );
			if(_dirty) cleanPolygon();
			
			return (mat) ? Vector2.rotateByMatrix(_axes[index], mat) : _axes[index].clone();
		}
		
		public function getAxes(mat:Matrix=null):Array
		{
			if(_dirty) cleanPolygon();
			
			var arr:Array = new Array();
			
			while(arr.length < _axes.length)
			{
				arr.push( (mat) ? Vector2.rotateByMatrix(_axes[arr.length], mat) : _axes[arr.length].clone() );
			}
			
			return arr;
		}
		
		public function getAxisNorm(index:int, mat:Matrix=null):Vector2
		{
			return Vector2.normal( getAxis(index, mat) );
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{	
			if(_dirty) cleanPolygon();
			
			var arr:Array = new Array();
			
			while(arr.length < _axes.length)
			{
				arr.push( Vector2.normal( getAxis(arr.length, mat) ) );
			}
			
			return arr;
		}
		
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{
			if(!this.numVerts) return null;
			
			axis = Vector2.normalize(axis);
			
			var dots:Array = new Array();
			var ln:int = _vX.length;
			var v:Vector2 = new Vector2();
			for( var i:int = 0; i < ln; i++ )
			{
				v.setTo( _vX[i], _vY[i] );
				if(mat) v.transformByMatrix(mat);
				dots.push(v.dot(axis));
			}
			
			dots.sort(Array.NUMERIC);
			var min:Number = dots[0];
			var max:Number = dots[dots.length - 1];
			return new Interval(min, max, axis);
		}
		
		public function findExtremitiesOver(axis:Vector2, mat:Matrix=null):Array
		{
			axis = Vector2.normalize(axis);
			
			var verts:Array = this.getVertList(mat);
			
			var vert:Vector2, dot:Number, contacts:Array, min:Number = Number.POSITIVE_INFINITY;
			
			for each(vert in verts)
			{
				dot = axis.dot(vert);
				
				if(dot < min + LoDMath.SHORT_EPSILON)
				{
					if( Math.abs(min - dot) < LoDMath.SHORT_EPSILON )
					{
						contacts = [ contacts[0], vert ];
					} else {
						contacts = [vert];
						min = dot;
					}
				}
			}
			return contacts;
		}
		
	/**
	 * Private methods
	 */
	 	private function cleanPolygon():void
	 	{
	 		_center = computeSimpleCenter();
	 		_axes = computeAxes();
	 		_dirty = false;
	 	}
		
		private function computeSimpleCenter():Vector2
		{
			var ln:int = _vX.length;
			var ix:Number = 0;
			var iy:Number = 0;
			
			for( var i:int = 0; i < ln; i++ )
			{
				ix += _vX[i];
				iy += _vY[i];
			}
			
			ix /= ln;
			iy /= ln;
			
			return new Vector2( ix, iy );
		}
		
		private function computeAxes():Array
		{
			var ln:int = _vX.length;
			var arr:Array = new Array();
			var v:Vector2;
			
			for( var i:int = 0; i < ln; i++ )
			{
				var j:int = (i + 1) % ln;
				v = new Vector2( _vX[j] - _vX[i], _vY[j] - _vY[i] );
				v.normalize();
				arr.push(v);
			}
			
			return arr;
		}
	/**
	 * Bullshit Methods
	 */
		public function drawToGraphics( gr:Graphics, mat:Matrix=null ):void
		{	
			if(!this.numVerts) return;
			
			var arr:Array = this.getVertList(mat);
			var st:Vector2 = arr.shift() as Vector2;
			gr.moveTo(st.x, st.y);
			
			while(arr.length)
			{
				var pnt:Vector2 = arr.shift() as Vector2;
				gr.lineTo(pnt.x, pnt.y);
			}
			
			gr.lineTo(st.x, st.y);
		}
	}
}