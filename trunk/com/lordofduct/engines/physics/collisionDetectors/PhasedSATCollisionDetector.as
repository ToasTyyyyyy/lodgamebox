package com.lordofduct.engines.physics.collisionDetectors
{
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.LoDPhysicsEngine;
	import com.lordofduct.engines.physics.collisionMesh.IPhasedCollisionMesh;
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	import com.lordofduct.util.SingletonEnforcer;
	
	public class PhasedSATCollisionDetector extends SATCollisionDetector
	{
		private static var _inst:PhasedSATCollisionDetector;
		
		public static function get instance():PhasedSATCollisionDetector
		{
			if (!_inst) _inst = SingletonEnforcer.gi(PhasedSATCollisionDetector);
			
			return _inst;
		}
		
		public function PhasedSATCollisionDetector()
		{
			//SingletonEnforcer.assertSingle(PhasedSATCollisionDetector);
			super(PhasedSATCollisionDetector);
		}
/**
 * Class Definition
 */
		
		override public function get weight():Number { return 2.1; }
		
		override public function testBodyBody(body1:IPhysicalAttrib, body2:IPhysicalAttrib, resolve:Boolean=false, resAlg:ICollisionResolver=null):*
		{
			if(!body1 || !body2) return null;
			
			//get the phased meshes
			var mesh1:IPhasedCollisionMesh = body1.collisionMesh as IPhasedCollisionMesh;
			var mesh2:IPhasedCollisionMesh = body2.collisionMesh as IPhasedCollisionMesh;
			
			//if neither mesh is phased, then just do a regular SAT collision detection
			if(!mesh1 && !mesh2) return super.testBodyBody(body1, body2, resolve, resAlg);
			
			//prepare a value to store collision results
			var results:Array = new Array(), res:CollisionResult;
			var tp1:int, tp2:int, tpa:int, m1p:int, m2p:int;
			
			//retrieve the totalphases
			tp1 = (mesh1) ? mesh1.totalPhases : 1;
			tp2 = (mesh2) ? mesh2.totalPhases : 1;
			tpa = tp1 * tp2;
			
			//now test each mesh in its various phases against each other
			for (var i:int = 0; i < tpa; i++)
			{
				m1p = i % tp1;
				m2p = Math.floor( i / tp1 );
				if(mesh1) mesh1.currentPhase = m1p;
				if(mesh2) mesh2.currentPhase = m2p;
				
				res = testAbstractMesh( body1.collisionMesh, body2.collisionMesh, body1.physicalTransform.matrix, body2.physicalTransform.matrix );
				
				if(res)
				{
					res.body1 = body1;
					res.body2 = body2;
					res.body1phase = (mesh1) ? m1p : -1;
					res.body2phase = (mesh2) ? m2p : -1;
					results.push(res);
				}
				
				LoDPhysicsEngine.instance.poolCollisionResult( res, resolve, resAlg );
			}
			
			//reset mesh phase positions before completing
			if(mesh1) mesh1.currentPhase = -1;
			if(mesh2) mesh2.currentPhase = -1;
			
			return (results.length) ? results : null;
		}
	}
}