package com.lordofduct.engines.physics.collisionMesh
{
	import com.lordofduct.engines.physics.collisionDetectors.ICollisionDetector;
	import com.lordofduct.engines.physics.collisionDetectors.SATCollisionDetector;
	import com.lordofduct.geom.IGeometricShape;
	import com.lordofduct.geom.Interval;
	import com.lordofduct.geom.Ray2D;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.Assertions;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class ConvexHullCollectionMesh implements ICollisionMesh
	{
		private var _alg:ICollisionDetector;
		private var _geom:Array = new Array();
		private var _rect:Rectangle;
		
		public function ConvexHullCollectionMesh(geom:*, alg:ICollisionDetector=null)
		{
			_alg = (alg) ? alg : SATCollisionDetector.instance;
			
			_geom = _geom.concat(geom);
			Assertions.allAreCompatible(_geom, IGeometricShape, "com.lordofduct.engines.physics.collisionMesh::ConvexHullMesh - geom param must be of type Array or IGeometricShape" );
			invalidate();
		}
/**
 * Properties
 */
		public function get geometry():Array { return _geom.slice(); }
		public function set geometry(value:Array):void
		{
			_geom = (value) ? value.slice() : null;
			Assertions.allAreCompatible(_geom, IGeometricShape, "com.lordofduct.engines.physics.collisionMesh::ConvexHullMesh - geom param must be of type Array or IGeometricShape" );
			invalidate();
		}
	/**
	 * ICollisionMesh Interface
	 */
		/**
		 * A rectangle describing the bounds of the object locally (with respect to its own local space).
		 */
		public function get boundingRect():Rectangle
		{
			//TODO
			
			return null;
		}
		
		/**
		 * The algorithm this mesh utilizes for detecting collision with other objects.
		 */
		public function get collisionDetector():ICollisionDetector { return _alg; }
		
		public function get tensorLength():Number
		{
			return 1;
		}
		
		public function getCenterOfMass(mat:Matrix=null):Vector2
		{
			//TODO: solve this for once damn it
			return new Vector2();
		}
		
/**
 * Methods
 */
	/**
	 * ICollisionMesh Interface
	 */
		public function invalidate():void
		{
			
		}
		
		public function getAxes(mat:Matrix=null):Array
		{
			var arr:Array = new Array();
			
			for each( var geom:IGeometricShape in _geom )
			{
				arr.push.apply(arr, geom.getAxes(mat));
			}
			
			return arr;
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{
			var arr:Array = new Array();
			
			for each( var geom:IGeometricShape in _geom )
			{
				arr.push.apply(arr, geom.getAxesNorms(mat));
			}
			
			return arr;
		}
		
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{
			var inter:Interval, temp:Interval;
			
			for each( var geom:IGeometricShape in _geom )
			{
				temp = geom.projectOntoAxis(axis, mat);
				
				if(!inter) inter = temp;
				else if(temp) inter.concat(temp);
			}
		}
		
		public function findNearestContacts(axis:Vector2, mat:Matrix=null):Array
		{
			return null;
		}
		
		public function castRayThrough(ray:Ray2D, mat:Matrix=null, dist:Number=NaN, epsilon:Number=0.0001):Array
		{
			return null;
		}
		
	}
}