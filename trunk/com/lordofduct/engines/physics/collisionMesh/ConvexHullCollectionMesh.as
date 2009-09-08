package com.lordofduct.engines.physics.collisionMesh
{
	import com.lordofduct.engines.physics.collisionDetectors.ICollisionDetector;
	import com.lordofduct.engines.physics.collisionDetectors.PhasedSATCollisionDetector;
	import com.lordofduct.geom.IGeometricShape;
	import com.lordofduct.geom.Interval;
	import com.lordofduct.geom.Ray2D;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class ConvexHullCollectionMesh implements IPhasedCollisionMesh
	{
		private var _alg:ICollisionDetector;
		private var _geom:Array = new Array();
		private var _rect:Rectangle;
		private var _tl:Number;
		private var _cent:Vector2;
		
		private var _curPhase:int = -1;
		
		public function ConvexHullCollectionMesh(geom:*, alg:ICollisionDetector=null)
		{
			_alg = (alg) ? alg : PhasedSATCollisionDetector.instance;
			
			_geom = _geom.concat( geom );
			Assertions.allAreCompatible(_geom, IGeometricShape, "com.lordofduct.engines.physics.collisionMesh::ConvexHullMesh - geom param must be of type Array or IGeometricShape" );
			invalidate();
		}
/**
 * Properties
 */
		public function get geometry():Array { return _geom.slice(); }
		public function set geometry(value:Array):void
		{
			_geom = (value) ? value.slice() : new Array();
			Assertions.allAreCompatible(_geom, IGeometricShape, "com.lordofduct.engines.physics.collisionMesh::ConvexHullMesh - geom param must be of type Array and filled with IGeometricShapes" );
			invalidate();
			_curPhase = LoDMath.clamp( _curPhase, this.totalPhases - 1, -1 );
		}
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
			_alg = (value) ? value : PhasedSATCollisionDetector.instance;
		}
		
		public function get tensorLength():Number
		{
			return _tl;
		}
		
		public function getCenterOfMass(mat:Matrix=null):Vector2
		{
			if (_curPhase < 0)
			{
				return (mat) ? Vector2.transformByMatrix( _cent, mat ) : _cent.clone();
			} else {
				return _geom[_curPhase].getSimpleCenter(mat);
			}
		}
		
	/**
	 * IPhasedCollisionMesh Interface
	 */
		public function get totalPhases():int { return _geom.length; }
		
		public function get currentPhase():int { return _curPhase; }
		public function set currentPhase(value:int):void { _curPhase = LoDMath.clamp( value, this.totalPhases - 1, -1 ); }
		
/**
 * Methods
 */
	/**
	 * ICollisionMesh Interface
	 */
		public function invalidate():void
		{
			//find bounding rect and simple center
			_rect = new Rectangle();
			_cent = new Vector2();
			
			for each( var geom:IGeometricShape in _geom )
			{
				_rect = _rect.union( geom.getBoundingRect() );
				_cent.add( geom.getSimpleCenter() );
			}
			
			_cent.divide( Math.max( 1, _geom.length) );
			
			//find tensor length
			var l:Number = Math.max(_rect.width, _rect.height);
			l /= 2;
			_tl = l * l;
		}
		
		public function getAxes(mat:Matrix=null):Array
		{	
			if(_curPhase < 0)
			{
				var arr:Array = new Array();
				
				for each( var geom:IGeometricShape in _geom )
				{
					arr.push.apply(arr, geom.getAxes(mat));
				}
				
				return arr;
			} else
			{
				//if we are in some phase, then find axes of that phase
				
				return _geom[_curPhase].getAxes(mat);
			}
		}
		
		public function getAxesNorms(mat:Matrix=null):Array
		{
			if(_curPhase < 0)
			{
				var arr:Array = new Array();
				
				for each( var geom:IGeometricShape in _geom )
				{
					arr.push.apply(arr, geom.getAxesNorms(mat));
				}
				
				return arr;
			} else
			{
				//if we are in some phase, then find axes norms of that phase
				
				return _geom[_curPhase].getAxesNorms(mat);
			}
		}
		
		public function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		{
			if(_curPhase < 0)
			{
				var inter:Interval, temp:Interval;
				
				for each( var geom:IGeometricShape in _geom )
				{
					temp = geom.projectOntoAxis(axis, mat);
					
					if(!inter) inter = temp;
					else if(temp) inter.concat(temp);
				}
				
				return inter;
			} else
			{
				//if we are in some phase, project only that phase
				
				return _geom[_curPhase].projectOntoAxis( axis, mat);
			}
		}
		
		public function findNearestContacts(axis:Vector2, mat:Matrix=null):Array
		{
			if(_curPhase < 0)
			{
				var verts:Array = new Array();
				
				for each( var geom:IGeometricShape in _geom )
				{
					verts.push.apply( verts, geom.findExtremitiesOver( axis, mat ) );
				}
				
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
			} else
			{
				//if we are in some phase, then find contacts of that phase
				
				var arr:Array = _geom[_curPhase].findExtremitiesOver(axis,mat);
				return arr;
			}
		}
		
		public function castRayThrough(ray:Ray2D, mat:Matrix=null, dist:Number=NaN, epsilon:Number=0.0001):Array
		{
			return null;
		}
		
	}
}