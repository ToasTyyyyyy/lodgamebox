package com.lordofduct.engines.physics.collisionDetectors
{
	import com.lordofduct.engines.physics.Collision;
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.LoDPhysicsEngine;
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class AABBCollision extends Collision
	{
		public function AABBCollision(b1:IPhysicalAttrib, b2:IPhysicalAttrib)
		{
			super(b1, b2, 0);
		}
		
		override public function collides():Boolean
		{
			var res:CollisionResult = AABBCollision.testBodyBody( this.body1, this.body2 );
			if(!res) return false;
			
			this.updateByCollisionResult( res );
			
			return true;
		}
		
		override public function getContacts():Array
		{
			return null;
		}
		
/**
 * STATIC INTERFACE
 */
		static public function testBodyBody( body1:IPhysicalAttrib, body2:IPhysicalAttrib ):*
		{
			if(!body1 || !body2) return null;
			
			var res:CollisionResult = testAbstractMesh( body1.collisionMesh, body2.collisionMesh, body1.physicalTransform.matrix, body2.physicalTransform.matrix );
			if(res)
			{
				res.body1 = body1;
				res.body2 = body2;
			}
			
			LoDPhysicsEngine.instance.poolCollisionResult( res );
			
			return res;
		}
		
		/**
		 * tests the bounding boxes of two CollisionMesh objects. Upon overlap a CollisionResult is returned.
		 */
		static public function testAbstractMesh( mesh1:ICollisionMesh, mesh2:ICollisionMesh, mat1:Matrix=null, mat2:Matrix=null ):CollisionResult
		{	
			if(!mesh1 || !mesh2) return null;
			
			var rect1:Rectangle = mesh1.boundingRect;
			var rect2:Rectangle = mesh2.boundingRect;
			if(!rect1 || !rect2) return null;
			if(!mat1) mat1 = new Matrix();
			if(!mat2) mat2 = new Matrix();
			
			rect1 = LoDMath.transformRectByMatrix( rect1, mat1 );
			rect2 = LoDMath.transformRectByMatrix( rect2, mat2 );
			return tessAABBvsAABB( rect1, rect2 );
		}
		
		static public function tessAABBvsAABB( rect1:Rectangle, rect2:Rectangle ):CollisionResult
		{
			var inter:Rectangle = rect1.intersection(rect2);
			
			if(!(inter.width > 0 && inter.height > 0)) return null;
			
			var penAxis:Vector2, normal:Vector2;
			var depth:Number = (inter.width > inter.height) ? inter.height : inter.width;
			
			if(inter.width > inter.height)
			{
				penAxis = Vector2.UnitY;
				if( rect1.top > rect2.top ) penAxis.negate();
			} else {
				penAxis = Vector2.UnitX;
				if( rect1.left > rect2.left ) penAxis.negate();
			}
			
			normal = Vector2.normal(penAxis);
			return new CollisionResult( penAxis, normal, depth );
		}
	}
}