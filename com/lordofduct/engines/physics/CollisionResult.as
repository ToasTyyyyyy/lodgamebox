package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.IClonable;
	import com.lordofduct.util.IDisposable;
	
	final public class CollisionResult implements IDisposable, IClonable
	{
		/**
		 * Initial properties set by constructor when a collision occurs. Normal is with respect to 
		 * collission groups global transform.
		 * 
		 * normal - vector pointing direction of collision from body1 -> body2
		 * depth - Absolute value of how deep the overlap is
		 */
		public var penetrationAxis:Vector2;
		public var normal:Vector2;//essentially the separating axis
		public var depth:Number = 0;//is the depth across the normal perpendicular that the two body's intersect
		public var overlaps:Array;//a list intervals describing several axes on which the two bodies overlap
		/**
		 * Properties set by Physics Engine before calculating reaction values
		 * 
		 * body1 - the object colliding
		 * body2 - the object being collided with
		 */
		public var body1:IPhysicalAttrib;
		public var body2:IPhysicalAttrib;
		public var collisionResolver:ICollisionResolver;
		
		private var _haulted:Boolean = false;
		
		public function CollisionResult( penAxis:Vector2=null, norm:Vector2=null, dep:Number=NaN, olaps:Array=null, b1:IPhysicalAttrib=null, b2:IPhysicalAttrib=null)
		{
			penetrationAxis = penAxis;
			normal = norm;
			depth = dep;
			overlaps = olaps;
			body1 = b1;
			body2 = b2
		}
		/**
		 * did the collision get haulted at any point during resolving the collision
		 */
		public function get haulted():Boolean { return _haulted; }
		
		/**
		 * When this object is captured during a CollisionEvent run this method 
		 * to stop the Physics Engine from going any further with resolving the collision.
		 * 
		 * This can be done at two points.
		 * 
		 * After the collision is detected AND Before the actual physics is calculated => CollisionEvent.Collision
		 * After the physics is calculated AND Before the actual physics are resolved => CollisionEvent.Collision_CALCULATED
		 */
		public function haultCollision():void
		{
			_haulted = true;
		}
		
	/**
	 * IDisposable Interface
	 */
		public function reengage(...args):void
		{
			this.penetrationAxis = args[0];
			this.normal = args[1];
			this.depth = args[2];
			this.overlaps = args[3];
			this.body1 = args[4];
			this.body2 = args[5];
		}
		
		public function dispose():void
		{
			body1 = null;
			body2 = null;
			normal = null;
			depth = 0;
			overlaps = null;
			penetrationAxis = null;
			haultCollision();//if disposed at any point, hault the collision
		}
		
	/**
	 * IClonable Interface
	 */
		public function copy( obj:* ):void
		{
			var res:CollisionResult = obj as CollisionResult;
			if(res)
			{
				this.penetrationAxis = res.penetrationAxis.clone();
				this.normal = res.normal.clone();
				this.depth = res.depth;
				this.overlaps = res.overlaps.slice();
				this.body1 = res.body1;
				this.body2 = res.body2;
			}
		}
		
		public function clone():*
		{
			var cr:CollisionResult = new CollisionResult();
			cr.penetrationAxis = this.penetrationAxis.clone();
			cr.normal = this.normal.clone();
			cr.depth = this.depth;
			cr.overlaps = this.overlaps.slice();
			cr.body1 = this.body1;
			cr.body2 = this.body2;
		}
	}
}