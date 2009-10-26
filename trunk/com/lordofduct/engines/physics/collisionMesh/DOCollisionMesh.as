package com.lordofduct.engines.physics.collisionMesh
{
	import com.lordofduct.engines.physics.collisionDetectors.AABBCollision;
	import com.lordofduct.geom.Interval;
	import com.lordofduct.geom.Ray2D;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class DOCollisionMesh implements ICollisionMesh
	{
		private var _alg:Class;
		
		private var _disObj:DisplayObject;
		private var _rect:Rectangle;
		private var _tl:Number;
		
		public function DOCollisionMesh( disObj:DisplayObject, alg:Class=null )
		{
			_alg = (alg) ? alg : AABBCollision;
			
			Assertions.notNil( disObj, "com.lordofduct.engines.physics.collisionMesh::DOCollisionMesh - related DisplayObject must be non-null." );
			_disObj = disObj;
			
			this.invalidate();
		}

/**
 * Properties
 */
		public function get relatedDisplayObject():DisplayObject { return _disObj; }
		public function set relatedDisplayObject(value:DisplayObject):void
		{
			Assertions.notNil( value, "com.lordofduct.engines.physics.collisionMesh::DOCollisionMesh - related DisplayObject must be non-null." );
			
			_disObj = value;
			this.invalidate();
		}
		
	/**
	 * ICollisionMesh Interface
	 */
		public function get boundingRect():Rectangle { return _rect; }
		
		public function get collisionDetector():Class { return _alg; }
		public function set collisionDetector(value:Class):void
		{
			_alg = (value) ? value : AABBCollision;
		}
		
		public function get tensorLength():Number { return _tl; }
		
/**
 * Methods
 */
	/**
	 * ICollisionMesh Interface
	 */
		public function invalidate():void
		{
			_rect = _disObj.getRect(_disObj);
			
			var l:Number = Math.max(_rect.width, _rect.height);
			l /= 2;
			_tl = l * l;
		}
		
		public function getCenterOfMass(mat:Matrix=null):Vector2
		{
			var cm:Vector2 = new Vector2( (_rect.right - _rect.left) / 2, (_rect.bottom - _rect.top) / 2 );
			if(mat) cm.transformByMatrix(mat);
			return cm;
		}
		
		public function getAxes(mat:Matrix=null):Array
		{
			if(!mat) mat = new Matrix();
			return [ new Vector2(mat.a, mat.b), new Vector2(mat.c, mat.d) ];
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{
			if(!mat) mat = new Matrix();
			return [ new Vector2(-mat.c, -mat.d), new Vector2(mat.a, mat.b) ];
		}
		
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{
			var pnt:Vector2 = new Vector2();
			var dots:Array = new Array();
			axis = Vector2.normalize(axis);
			
			pnt.copy( _rect.topLeft );
			if(mat) pnt.transformByMatrix(mat);
			dots.push(pnt.dot(axis));
			
			pnt.copy( _rect.bottomRight );
			if(mat) pnt.transformByMatrix(mat);
			dots.push(pnt.dot(axis));
			
			pnt.setTo( _rect.left, _rect.bottom );
			if(mat) pnt.transformByMatrix(mat);
			dots.push( pnt.dot(axis) );
			
			pnt.setTo( _rect.right, _rect.top );
			if(mat) pnt.transformByMatrix(mat);
			dots.push( pnt.dot(axis) );
			
			dots.sort(Array.NUMERIC);
			var min:Number = dots[0];
			var max:Number = dots[dots.length - 1];
			return new Interval(min, max, axis);
		}
		
		public function findNearestContacts(axis:Vector2, mat:Matrix=null):Array
		{
			var verts:Array = [ Vector2.copy(_rect.topLeft), 
								new Vector2(_rect.right, _rect.top), 
								Vector2.copy(_rect.bottomRight), 
								new Vector2(_rect.left, _rect.bottom) ];
			
			axis = Vector2.normalize(axis);
			
			var vert:Vector2, dot:Number, contacts:Array, min:Number = Number.POSITIVE_INFINITY;		
			
			for each(vert in verts)
			{
				if(mat) vert.transformByMatrix(mat);
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
		
		public function castRayThrough(ray:Ray2D, mat:Matrix=null, dist:Number=NaN, epsilon:Number=0.0001):Array
		{
			return null;
		}
		
	}
}