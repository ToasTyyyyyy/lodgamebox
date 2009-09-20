/**
 * SimpleCollisionResolver - written by Dylan Engelman a.k.a LordOfDuct
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
 * This algorithm is for use when resolving collisions in LoDPhysicsEngine. This algorithm 
 * merely moves the two objects apart so that they are no longer colliding. No impulse is 
 * generated between the two.
 * 
 * So if body1 is dynamic and body2 is static, then body1 will just be moved back a tiny bit 
 * to stop them from overlapping. If body1 AND body2 are dynamic, then both are moved half the 
 * depth apart from each other so they no longer overlap.
 * 
 * This concludes the most basic of collision resolution. This is useful for a none-realistic 
 * physical collision.
 */
package com.lordofduct.engines.physics.collisionResolvers
{
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.engines.physics.LoDPhysicsEngine;
	import com.lordofduct.events.PhysicsEvent;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.SingletonEnforcer;

	public class SimpleCollisionResolver implements ICollisionResolver
	{
		private static var _inst:SimpleCollisionResolver;
		
		public static function get instance():SimpleCollisionResolver
		{
			if (!_inst) _inst = SingletonEnforcer.gi(SimpleCollisionResolver);
			
			return _inst;
		}
		
		public function SimpleCollisionResolver()
		{
			SingletonEnforcer.assertSingle(SimpleCollisionResolver);
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
				sim1.velocity.reflect(Vector2.normalize(mtdA));
			}
			if(sim2 && sim2.isDynamicMass)
			{
				sim2.physicalTransform.x += mtdB.x;
				sim2.physicalTransform.y += mtdB.y;
				sim2.velocity.reflect(Vector2.normalize(mtdB));
			}
			
			LoDPhysicsEngine.instance.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body1.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body1.dispatchEvent( new PhysicsEvent( PhysicsEvent.BODY_MOVED, result ) );
			body2.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body2.dispatchEvent( new PhysicsEvent( PhysicsEvent.BODY_MOVED, result ) );
		}
	}
}