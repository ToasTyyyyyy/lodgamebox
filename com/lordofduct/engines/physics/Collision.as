package com.lordofduct.engines.physics
{
	import com.lordofduct.geom.Vector2;
	
	public class Collision
	{
		private var _weight:Number;
		private var _body1:IPhysicalAttrib;
		private var _body2:IPhysicalAttrib;
		
		private var _penAxis:Vector2;
		private var _normal:Vector2;//essentially the separating axis
		private var _depth:Number = 0;//is the depth across the normal perpendicular that the two body's intersect
		
		public function Collision(b1:IPhysicalAttrib, b2:IPhysicalAttrib, wght:Number=-1)
		{
			_weight = wght;
			_body1 = b1;
			_body2 = b2;
		}
		
/**
 * Properties
 */
		public function get weight():Number { return _weight; }
		
		public function get body1():IPhysicalAttrib { return _body1; }
		public function get body2():IPhysicalAttrib { return _body2; }
		
		public function get penetrationAxis():Vector2 { return _penAxis; }
		public function set penetrationAxis(value:Vector2):void { _penAxis = value; }
		
		public function get normal():Vector2 { return _normal; }
		public function set normal(value:Vector2):void { _normal = value; }
		
		public function get depth():Number { return _depth; }
		public function set depth(value:Number):void { _depth = value; }
		
/**
 * Methods
 */
		public function collides():Boolean
		{
			return false;
		}
		
		public function getContacts():Array
		{
			return null;
		}
		
		public function updateParameters( penAxis:Vector2, norm:Vector2, dep:Number ):void
		{
			_penAxis = penAxis;
			_normal = norm;
			_depth = dep;
		}
		
		public function updateByCollisionResult( res:CollisionResult ):void
		{
			_penAxis = res.penetrationAxis;
			_normal = res.normal;
			_depth = depth;
		}
	}
}