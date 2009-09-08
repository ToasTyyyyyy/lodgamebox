package com.lordofduct.engines.physics.collisionMesh
{
	import com.lordofduct.engines.physics.collisionDetectors.ICollisionDetector;
	import com.lordofduct.engines.physics.collisionDetectors.SATCollisionDetector;
	import com.lordofduct.geom.IGeometricShape;
	import com.lordofduct.geom.Interval;
	import com.lordofduct.geom.Ray2D;
	import com.lordofduct.geom.Vector2;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class ConvexHullMesh implements ICollisionMesh
	{
		private var _alg:ICollisionDetector;
		private var _geom:IGeometricShape;
		private var _rect:Rectangle;
		private var _tl:Number = 1;
		
		public function ConvexHullMesh(geom:IGeometricShape, alg:ICollisionDetector=null)
		{
			_alg = (alg) ? alg : SATCollisionDetector.instance;
			this.geometry = geom;
			invalidate();
		}
/**
 * Properties
 */
		public function get geometry():IGeometricShape { return _geom; }
		public function set geometry(value:IGeometricShape):void { _geom = value; invalidate(); }
	/**
	 * ICollisionMesh Interface
	 */
		/**
		 * A rectangle describing the bounds of the object locally (with respect to its own local space).
		 */
		public function get boundingRect():Rectangle
		{
			return _rect.clone();
		}
		
		/**
		 * The algorithm this mesh utilizes for detecting collision with other objects.
		 */
		public function get collisionDetector():ICollisionDetector { return _alg; }
		public function set collisionDetector(value:ICollisionDetector):void
		{
			_alg = (value) ? value : SATCollisionDetector.instance;
		}
		
		public function get tensorLength():Number
		{
			return _tl;
		}
		
		public function getCenterOfMass(mat:Matrix=null):Vector2
		{
			return _geom.getSimpleCenter(mat);
		}
		
/**
 * Methods
 */
	/**
	 * ICollisionMesh Interface
	 */
		public function invalidate():void
		{
			_rect = (_geom) ? _geom.getBoundingRect() : new Rectangle();
			
			/* var l:Number = Math.max(_rect.width, _rect.height);
			l /= 2;
			_tl = l * l; */
			var l:Number = _rect.size.length / 2;
			_tl = l * l;
		}
		
		public function getAxes(mat:Matrix=null):Array
		{
			return _geom.getAxes(mat);
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{
			return _geom.getAxesNorms(mat);
		}
		
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{	
			return _geom.projectOntoAxis(axis, mat);
		}
		
		public function findNearestContacts(axis:Vector2, mat:Matrix=null):Array
		{
			return _geom.findExtremitiesOver(axis,mat);
		}
		
		public function castRayThrough(ray:Ray2D, mat:Matrix=null, dist:Number=NaN, epsilon:Number=0.0001):Array
		{
			return null;
		}
	}
}