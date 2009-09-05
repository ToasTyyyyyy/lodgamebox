package com.lordofduct.engines.physics.collisionDetectors
{
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.LoDPhysicsEngine;
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	import com.lordofduct.events.PhysicsEvent;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.geom.Matrix;
	
	public class BitmapCollisionDetector implements ICollisionDetector
	{
		private static var _inst:BitmapCollisionDetector;
		
		public static function get instance():BitmapCollisionDetector
		{
			if (!_inst) _inst = SingletonEnforcer.gi(BitmapCollisionDetector);
			
			return _inst;
		}
		
		public function BitmapCollisionDetector()
		{
			SingletonEnforcer.assertSingle(BitmapCollisionDetector);
		}
		
/**
 * Class Definition
 */
		public function get weight():Number { return 1; }
		
		public function testBodyBody( body1:IPhysicalAttrib, body2:IPhysicalAttrib, resolve:Boolean=false, resAlg:ICollisionResolver=null ):*
		{
			if(!body1 || !body2) return null;
			
			var res:CollisionResult = testAbstractMesh( body1.collisionMesh, body2.collisionMesh, body1.physicalTransform.matrix, body2.physicalTransform.matrix );
			if(res)
			{
				res.body1 = body1;
				res.body2 = body2;
			}
			
			LoDPhysicsEngine.instance.poolCollisionResult( res, resolve, resAlg );
			
			return res;
		}
		
		public function testAbstractMesh( mesh1:ICollisionMesh, mesh2:ICollisionMesh, mat1:Matrix=null, mat2:Matrix=null ):CollisionResult
		{
			return null;
		}
	}
}