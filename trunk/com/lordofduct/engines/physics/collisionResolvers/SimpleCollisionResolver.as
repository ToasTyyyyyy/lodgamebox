package com.lordofduct.engines.physics.collisionResolvers
{
	import com.lordofduct.engines.physics.Arbiter;
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.collisionMesh.IPhasedCollisionMesh;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	
	public class SimpleCollisionResolver extends Arbiter
	{
		public function SimpleCollisionResolver(b1:IPhysicalAttrib, b2:IPhysicalAttrib)
		{
			super(b1, b2);
		}
		
		override public function update(results:Array):void
		{	
			for each( var result:CollisionResult in results )
			{
				if(body1.collisionMesh is IPhasedCollisionMesh)
				{
					IPhasedCollisionMesh(body1.collisionMesh).currentPhase = result.body1phase;
				}
				if(body2.collisionMesh is IPhasedCollisionMesh)
				{
					IPhasedCollisionMesh(body2.collisionMesh).currentPhase = result.body2phase;
				}
				
				if(Vector2.subtract(this.body1.centerOfMass, this.body2.centerOfMass).dot(result.penetrationAxis) < 0)
				{
					result.normal.negate();
					result.penetrationAxis.negate();
				}
			}
			
			if(body1.collisionMesh is IPhasedCollisionMesh)
			{
				IPhasedCollisionMesh(body1.collisionMesh).currentPhase = -1;
			}
			if(body2.collisionMesh is IPhasedCollisionMesh)
			{
				IPhasedCollisionMesh(body2.collisionMesh).currentPhase = -1;
			}
			
			super.update(results);
		}
		
		override public function preStep(invDt:Number, dt:Number):void
		{
			//TODO
		}
		
		override public function applyImpulse():void
		{
			var results:Array = this.collisions;
			
			for each( var result:CollisionResult in results)
			{
				if(body1.collisionMesh is IPhasedCollisionMesh)
				{
					IPhasedCollisionMesh(body1.collisionMesh).currentPhase = result.body1phase;
				}
				if(body2.collisionMesh is IPhasedCollisionMesh)
				{
					IPhasedCollisionMesh(body2.collisionMesh).currentPhase = result.body2phase;
				}
				
				var sim1:ISimulatableAttrib = body1 as ISimulatableAttrib;
				var sim2:ISimulatableAttrib = body2 as ISimulatableAttrib;
				if(!sim1 && !sim2) return;
				if((sim1 && !sim1.isDynamicMass) && (sim2 && !sim2.isDynamicMass)) return;
				
				var normal:Vector2 = result.normal;
				var depth:Number = result.depth;
				
				//get base info
				var mtd:Vector2 = Vector2.normal(normal);
				mtd.multiply(depth);
				var mtdA:Vector2 = mtd.clone();
				var mtdB:Vector2 = mtd.clone();
				mtdB.negate();
				
				if( sim1 && sim1.isDynamicMass && sim2 && sim2.isDynamicMass )
				{
					mtdA.divide(2);
					mtdB.divide(2);
				}
				
				//resolve the collision
				if(sim1 && sim1.isDynamicMass)
				{
					sim1.physicalTransform.x += mtdA.x;
					sim1.physicalTransform.y += mtdA.y;
					//sim1.velocity.reflect(Vector2.normalize(mtdA));
					sim1.velocity.setTo(0,0);
				}
				if(sim2 && sim2.isDynamicMass)
				{
					sim2.physicalTransform.x += mtdB.x;
					sim2.physicalTransform.y += mtdB.y;
					sim2.velocity.reflect(Vector2.normalize(mtdB));
					sim2.velocity.setTo(0,0);
				}
			}
			
			if(body1.collisionMesh is IPhasedCollisionMesh)
			{
				IPhasedCollisionMesh(body1.collisionMesh).currentPhase = -1;
			}
			if(body2.collisionMesh is IPhasedCollisionMesh)
			{
				IPhasedCollisionMesh(body2.collisionMesh).currentPhase = -1;
			}
		}
	}
}