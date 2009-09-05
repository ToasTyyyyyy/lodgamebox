/**
 * FoamCollisionResolver - written by Dylan Engelman a.k.a LordOfDuct
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
 * 
 * ####-NOTE-####
 * 
 * This class is an interpretation of the collision resolving algorithm used in the Foam Physics Engine 
 * coded by Drew Cummins.
 * 
 * It is being included under the same MIT license outlined as follows from the Foam library:
 * 
-----------------------------------------------------
Copyright (c) 2007 Drew Cummins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
---------------------------------------------------------
 * 
 * 
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
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	public class FoamCollisionResolver implements ICollisionResolver
	{
		private static var _inst:FoamCollisionResolver;
		
		public static function get instance():FoamCollisionResolver
		{
			if (!_inst) _inst = SingletonEnforcer.gi(FoamCollisionResolver);
			
			return _inst;
		}
		
		public function FoamCollisionResolver()
		{
			SingletonEnforcer.assertSingle(FoamCollisionResolver);
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
			var body1:IPhysicalAttrib = result.body1;
			var body2:IPhysicalAttrib = result.body2;
			if(!body1 || !body2) return;//if either don't exist, then just leave now
			
			var sim1:ISimulatableAttrib = body1 as ISimulatableAttrib;
			var sim2:ISimulatableAttrib = body2 as ISimulatableAttrib;
			var b1Dynamic:Boolean = (sim1 && sim1.isDynamicMass);
			var b2Dynamic:Boolean = (sim2 && sim2.isDynamicMass);
			
			if(!b1Dynamic && !b2Dynamic) return;//if both are immobile then just leave now
			
			var penAxis:Vector2 = result.penetrationAxis.clone();
			var normal:Vector2 = result.normal.clone();
			var depth:Number = result.depth;
			
			if(Vector2.subtract(body1.centerOfMass, body2.centerOfMass).dot(penAxis) < 0)
			{
				normal.negate();
				penAxis.negate();
			}
			
			var contacts:Array = getContacts(body1, body2, normal, penAxis, depth);
			
			resolveImpulse(body1, body2, result.normal, penAxis, contacts);
			
			LoDPhysicsEngine.instance.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body1.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body1.dispatchEvent( new PhysicsEvent( PhysicsEvent.BODY_MOVED, result ) );
			body2.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION_RESOLVED, result ) );
			body2.dispatchEvent( new PhysicsEvent( PhysicsEvent.BODY_MOVED, result ) );
		}
		
		private function resolveImpulse(body1:IPhysicalAttrib, body2:IPhysicalAttrib, normal:Vector2, penAxis:Vector2, contacts:Array):void
		{
			var c1:Vector2 = body1.centerOfMass;
			var c2:Vector2 = body2.centerOfMass;
			var invM1:Number = body1.invMass;
			var invM2:Number = body2.invMass;
			var invI1:Number = body1.invInertiaTensor;
			var invI2:Number = body2.invInertiaTensor;
			
			for each( var contact:Vector2 in contacts )
			{
				/***** contact resolution impulse *****/
				
				//define contact point relative to each body (point given in world coordinates)
				//and set it perpendicular
				var contactPerp1:Vector2 = Vector2.subtract(contact, c1);
				contactPerp1.perp();
				var contactPerp2:Vector2 = Vector2.subtract(contact, c2);
				contactPerp2.perp();
				
				//dot this along the contact normal
				var contactPerpNorm1:Number = contactPerp1.dot( penAxis );
				var contactPerpNorm2:Number = contactPerp2.dot( penAxis );
				
				//define the denominator of the impulse
				var impulseDenominator:Number = invM1 + invM2;
				impulseDenominator += contactPerpNorm1 * contactPerpNorm1 * invI1;
				impulseDenominator += contactPerpNorm2 * contactPerpNorm2 * invI2;
				
				//find the velocity of each body at the point of contact
				var velAtCon1:Vector2 = new Vector2();
				if(body1 is ISimulatableAttrib && ISimulatableAttrib(body1).isDynamicMass)
				{
					velAtCon1.copy(contactPerp1);
					velAtCon1.multiply(ISimulatableAttrib(body1).angularVelocity);
					velAtCon1.add( ISimulatableAttrib(body1).velocity );
				}
				var velAtCon2:Vector2 = new Vector2();
				if(body2 is ISimulatableAttrib && ISimulatableAttrib(body2).isDynamicMass)
				{
					velAtCon2.copy(contactPerp2);
					velAtCon2.multiply(ISimulatableAttrib(body2).angularVelocity);
					velAtCon2.add(ISimulatableAttrib(body2).velocity);
				}
				
				//define the relative velocity at the point of contact
				var relativeVelocity:Vector2 = Vector2.subtract(velAtCon1, velAtCon2 );
				
				//dot this onto the contact normal
				var rvNorm:Number = relativeVelocity.dot( penAxis );
				
				//find the coefficient of restitution for this collision based upon each
				//body's elasticity property
				var restitution:Number = ( body1.elasticity + body2.elasticity ) * 0.5;
				
				//solve for the impulse to apply to each body
				var impulse:Number = -( 1 + restitution ) * rvNorm / impulseDenominator;
				
				//apply this along the contact normal for the change in linear velocity for body1
				//this vector will collect the frictional impulse as well
				var dlv1:Vector2 = Vector2.multiply(penAxis, impulse * invM1 );
				//apply this along the normal's perpindicular vector for angular velocity change
				var dav1:Number = contactPerp1.dot( Vector2.multiply(penAxis, impulse ) ) * invI1;
				
				//apply this along the contact normal for the change in linear velocity for body2
				//this vector will collect the frictional impulse as well
				var dlv2:Vector2 = Vector2.multiply( penAxis, -impulse * invM2 );
				//apply this along the normal's perpindicular vector for angular velocity change
				var dav2:Number = contactPerp2.dot( Vector2.multiply( penAxis, -impulse ) ) * invI2;
				
				/***** frictional impulse *****/
				 
				//define a tangent vector for friction calculation
				//it's 'normal'
				
				//dot this along our relative normal
				var contactPerpnormal1:Number = contactPerp1.dot( normal );
				var contactPerpnormal2:Number = contactPerp2.dot( normal );
				
				//define our equation's denominator for friction impulse just as we did with contact resolution impulse
				impulseDenominator = normal.dot( Vector2.multiply(normal, invM1 + invM2 ) ); 
				impulseDenominator += contactPerpnormal1 * contactPerpnormal1 * invI1;
				impulseDenominator += contactPerpnormal2 * contactPerpnormal2 * invI2;
				
				//define the relative velocity along the normal
				var rvnormal:Number = relativeVelocity.dot( normal );
				
				//solve for the frictional impulse to add to each body at contact
				impulse = -rvnormal / impulseDenominator * ( body1.friction + body2.friction ) * 0.5;
				
				//apply this along the contact normal for the change in linear velocity for body1
				dlv1.add( Vector2.multiply(normal, impulse * invM1 ) );
				//apply this along the normal's perpindicular vector for angular velocity change
				dav1 += contactPerp1.dot( Vector2.multiply(normal, impulse ) ) * invI1;
				
				//apply this along the contact normal for the change in linear velocity for body2
				dlv2.add( Vector2.multiply(normal, -impulse * invM2 ) );
				//apply this along the normal's perpindicular vector for angular velocity change
				dav2 += contactPerp2.dot( Vector2.multiply(normal, -impulse ) ) * invI2;
				
				if(body1 is ISimulatableAttrib && ISimulatableAttrib(body1).isDynamicMass)
				{
					ISimulatableAttrib(body1).velocity.add( dlv1 );
					ISimulatableAttrib(body1).angularVelocity += dav1;
				}
				if(body2 is ISimulatableAttrib && ISimulatableAttrib(body2).isDynamicMass)
				{
					ISimulatableAttrib(body2).velocity.add( dlv2 );
					ISimulatableAttrib(body2).angularVelocity += dav2;
				}
			}
		}
		
		private function getContacts(body1:IPhysicalAttrib, body2:IPhysicalAttrib, normal:Vector2, penAxis:Vector2, depth:Number ):Array
		{
			var axis:Vector2 = penAxis.clone();
			axis.multiply(depth);
			
			var b1inv:Number = (body1 is ISimulatableAttrib && ISimulatableAttrib(body1).isDynamicMass) ? body1.invMass : 0;
			var b2inv:Number = (body2 is ISimulatableAttrib && ISimulatableAttrib(body2).isDynamicMass) ? body2.invMass : 0;
			var sumInvMass:Number = b1inv + b2inv;
			if(!sumInvMass) return null;
			
			var mtdA:Vector2 = Vector2.multiply( axis, b1inv / sumInvMass );
			var mtdB:Vector2 = Vector2.multiply( axis, -b2inv / sumInvMass );
			
			//first move objects so they don't intersect
			if(body1 is ISimulatableAttrib && ISimulatableAttrib(body1).isDynamicMass)
			{
				body1.physicalTransform.x += mtdA.x;
				body1.physicalTransform.y += mtdA.y;
			}
			if(body2 is ISimulatableAttrib && ISimulatableAttrib(body2).isDynamicMass)
			{
				body2.physicalTransform.x += mtdB.x;
				body2.physicalTransform.y += mtdB.y;
			}
			
			//find contact point
			axis.copy(penAxis);
			
			var contacts1:Array = body1.collisionMesh.findNearestContacts(axis, body1.physicalTransform.matrix);
			
			//if only one contact point, then that is it
			if(contacts1.length == 1) return contacts1;
			
			axis.negate();
			var contacts2:Array = body2.collisionMesh.findNearestContacts(axis, body2.physicalTransform.matrix);
			
			//if only one contact point, then that is it
			if(contacts2.length == 1) return contacts2;
			
			//more then one contact, ok, let's figure out the best combination of points
			//THIS SUCKS, MUST CHANGE
			var cp:Dictionary = new Dictionary( true );
			var proj1:Number = normal.dot( contacts1[ 0 ] );
			var proj2:Number = normal.dot( contacts1[ 1 ] );
			var proj3:Number = normal.dot( contacts2[ 0 ] );
			var proj4:Number = normal.dot( contacts2[ 1 ] );
			cp[ proj1 ] = contacts1[ 0 ];
			cp[ proj2 ] = contacts1[ 1 ];
			cp[ proj3 ] = contacts2[ 0 ];
			cp[ proj4 ] = contacts2[ 1 ];
			
			
			var projections:Array = [ proj1, proj2, proj3, proj4 ];
			projections.sort( Array.NUMERIC );
			
			return [ cp[ projections[ 1 ] ], cp[ projections[ 2 ] ] ];
		}
	}
}