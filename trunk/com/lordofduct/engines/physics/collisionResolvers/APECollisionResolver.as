/**
 * APECollisionResolver - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * Copyright (c) 2009 Dylan Engelman
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, 
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject to the following 
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies 
 * or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * 
 * In other words, no guarantees are made that it will work as expected nor that I (Dylan Engelman) 
 * have to repair or give any assistance to you the user when you have troubles.
 * 
 * 
 * 
 * 
 * This algorithm is for use when resolving collisions in LoDPhysicsEngine. This 
 * algorithm is nearly a direct copy of the algorithm used in the APE physics 
 * engine (ver. alpha 0.45). No angular velocity is solved. The objects have an 
 * impulse generated based on elasticity and friction, and are moved apart so they 
 * aren't overlapping and then changes the velocity of each object based on this 
 * impulse.
 * 
 * This algorithm is included as an example for how to implement your own collision resolver 
 * algorithm in the LoD engine OR for those who prefer the algorithm found in APE. The algorithm 
 * is modified from the APE version to fit the interface of CollisionResult and Vector2, but for 
 * the most part remains the same. Credit is given directly to APE Physics Engine alpha 0.45 AND 
 * to the credit there in of Jim Bonacci.
 * 
 * Permission to use this Collision Resolver Algorithm given under the terms of the MIT license 
 * defined by Alec Cover (author of APE Physics Engine) in combination with the aforementioned 
 * license :
 * 
Copyright (c) 2006, 2007 Alec Cove

Permission is hereby granted, free of charge, to any person obtaining a copy of this 
software and associated documentation files (the "Software"), to deal in the Software 
without restriction, including without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to the following 
conditions:

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package com.lordofduct.engines.physics.collisionResolvers
{
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.engines.physics.LoDPhysicsEngine;
	import com.lordofduct.events.PhysicsEvent;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;
	import com.lordofduct.util.SingletonEnforcer;

	public class APECollisionResolver implements ICollisionResolver
	{
		private static var _inst:APECollisionResolver;
		
		public static function get instance():APECollisionResolver
		{
			if (!_inst) _inst = SingletonEnforcer.gi(APECollisionResolver);
			
			return _inst;
		}
		
		public function APECollisionResolver()
		{
			SingletonEnforcer.assertSingle(APECollisionResolver);
		}
/**
 * Class Definition
 */
		public function resolveCollisionPool( pool:Array ):void
		{
			for each( var result:CollisionResult in pool )
			{
				this.resolveCollision( result );
			}
		}

		public function resolveCollision(result:CollisionResult):void
		{
			if(result.haulted) return;
			
			var body1:IPhysicalAttrib = result.body1;
			var body2:IPhysicalAttrib = result.body2;
			var sim1:ISimulatableAttrib = body1 as ISimulatableAttrib;
			var sim2:ISimulatableAttrib = body2 as ISimulatableAttrib;
			if(!sim1 && !sim2) return;
			if((sim1 && !sim1.isDynamicMass) && (sim2 && !sim2.isDynamicMass)) return;
			
			var normal:Vector2 = result.normal;
			var depth:Number = result.depth;
			
			//get base info
			var penAxis = Vector2.normal(normal);
			if(Vector2.subtract(body1.centerOfMass, body2.centerOfMass).dot(penAxis) < 0)
			{
				normal.negate();
				penAxis.negate();
			}
			
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
			
			LoDPhysicsEngine.instance.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body1.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body1.dispatchEvent( new PhysicsEvent( PhysicsEvent.BODY_MOVED, result ) );
			body2.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body2.dispatchEvent( new PhysicsEvent( PhysicsEvent.BODY_MOVED, result ) );
		}
		
	}
}