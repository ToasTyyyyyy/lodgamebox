package com.lordofduct.engines.physics.collisionResolvers
{
	import com.lordofduct.engines.physics.Arbiter;
	import com.lordofduct.engines.physics.Collision;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.engines.physics.collisionMesh.IPhasedCollisionMesh;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;

	public class APECollisionResolver extends Arbiter
	{
		public function APECollisionResolver(b1:IPhysicalAttrib, b2:IPhysicalAttrib)
		{
			super(b1, b2);
		}
		
		override public function preStep(invDt:Number, dt:Number):void
		{
			if(!this.collision) return;
			//TODO
			
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
				var penAxis:Vector2 = Vector2.normal(normal);
				/* if(Vector2.subtract(body1.centerOfMass, body2.centerOfMass).dot(penAxis) < 0)
				{
					normal.negate();
					penAxis.negate();
				} */
				
				var mtd:Vector2 = Vector2.multiply(penAxis, depth);
				var te:Number = body1.elasticity + body2.elasticity;
				var sumInvMass:Number = body1.invMass + body2.invMass;
				var tf:Number = LoDMath.clamp( 1 - body1.friction + body2.friction, 1 );
				
				//get collision components
				var cavt:Vector2 = (sim1) ? sim1.velocity.clone() : new Vector2();
				var cavn:Vector2 = Vector2.multiply(penAxis, penAxis.dot(cavt));
				cavt.subtract(cavn);
				
				var cbvt:Vector2 = (sim2) ? sim2.velocity.clone() : new Vector2();
				var cbvn:Vector2 = Vector2.multiply(penAxis, penAxis.dot(cbvt));
				cbvt.subtract(cbvn);
				
				//calculate coefficient of restitution
				var vnA:Vector2 = Vector2.multiply( cbvn, (te + 1) * body1.invMass);
				vnA.add( Vector2.multiply( cavn, body2.invMass - te * body1.invMass));
				vnA.divide(sumInvMass);
				var vnB:Vector2 = Vector2.multiply( cavn, (te + 1) * body2.invMass);
				vnB.add( Vector2.multiply( cbvn, body1.invMass - te * body2.invMass));
				vnB.divide(sumInvMass);
				
				//apply friction to tangentials
				cavt.multiply(tf);
				cbvt.multiply(tf);
				
				//scale mtd
				var mtdA:Vector2 = Vector2.multiply( mtd, body1.invMass / sumInvMass );
				var mtdB:Vector2 = Vector2.multiply( mtd, -body2.invMass / sumInvMass );
				
				//add tangential to normal to get velocity
				vnA.add(cavt);
				vnB.add(cbvt);
				
				//resolve the collision
				if(sim1 && sim1.isDynamicMass)
				{
					sim1.physicalTransform.x += mtdA.x;
					sim1.physicalTransform.y += mtdA.y;
					sim1.velocity = vnA;
				}
				if(sim2 && sim2.isDynamicMass)
				{
					sim2.physicalTransform.x += mtdB.x;
					sim2.physicalTransform.y += mtdB.y;
					sim2.velocity = vnB;
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