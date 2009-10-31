package com.lordofduct.engines.physics.collisionResolvers
{
	import com.lordofduct.engines.physics.Arbiter;
	import com.lordofduct.engines.physics.Collision;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.engines.physics.collisionMesh.IPhasedCollisionMesh;
	import com.lordofduct.geom.Vector2;
	
	public class SimpleCollisionResolver extends Arbiter
	{
		public function SimpleCollisionResolver(b1:IPhysicalAttrib, b2:IPhysicalAttrib)
		{
			super(b1, b2);
		}
		
		override public function preStep(invDt:Number, dt:Number):void
		{
			if(!this.collision) return;
			
			var result:Collision = this.collision;
			
			if(Vector2.subtract(this.body1.centerOfMass, this.body2.centerOfMass).dot(result.penetrationAxis) < 0)
			{
				result.normal.negate();
				result.penetrationAxis.negate();
			}
			
			super.preStep( invDt, dt );
		}
		
		override public function applyImpulse():void
		{
			if(!this.collision) return;
			
			var result:Collision = this.collision;
			
			//ALGORITHM
				/* if(body1.collisionMesh is IPhasedCollisionMesh)
				{
					IPhasedCollisionMesh(body1.collisionMesh).currentPhase = result.body1phase;
				}
				if(body2.collisionMesh is IPhasedCollisionMesh)
				{
					IPhasedCollisionMesh(body2.collisionMesh).currentPhase = result.body2phase;
				} */
				
				var sim1:ISimulatableAttrib = body1 as ISimulatableAttrib;
				var sim2:ISimulatableAttrib = body2 as ISimulatableAttrib;
				if(!sim1 && !sim2) return;
				if((sim1 && !sim1.isDynamicMass) && (sim2 && !sim2.isDynamicMass)) return;
				
				var normal:Vector2 = result.normal;
				var depth:Number = result.depth;
				
				//get base info
				var mtd:Vector2 = Vector2.normal(normal);
				var mtdA:Vector2 = Vector2.multiply( mtd, depth );
				var mtdB:Vector2 = Vector2.multiply( mtd, -depth );
				
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
					
					//0 out the velocity in the direction of penetration
					var dotA:Number = sim1.velocity.dot( mtd );
					dotA = Math.max(dotA, 0);//only 0 out if sim is heading in relative direction of penetration
					dotA *= -1;//negate to go other direciton
					sim1.velocity.add( Vector2.multiply( mtd, dotA ) );
				}
				if(sim2 && sim2.isDynamicMass)
				{
					sim2.physicalTransform.x += mtdB.x;
					sim2.physicalTransform.y += mtdB.y;
					
					//0 out the velocity in the direction of penetration
					var dotB:Number = sim2.velocity.dot( Vector2.negate( mtd ) );
					dotB = Math.max( dotB, 0);//only 0 out if sim is heading in relative direction of penetration
					//dotB *= -1;
					sim2.velocity.add( Vector2.multiply( mtd, dotB ) );
				}
			//END ALGORITHM
			
			if(body1.collisionMesh is IPhasedCollisionMesh)
			{
				IPhasedCollisionMesh(body1.collisionMesh).currentPhase = -1;
			}
			if(body2.collisionMesh is IPhasedCollisionMesh)
			{
				IPhasedCollisionMesh(body2.collisionMesh).currentPhase = -1;
			}
			
			super.applyImpulse();
		}
	}
}