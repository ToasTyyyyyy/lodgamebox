package com.lordofduct.engines.physics.collisionResolvers
{
	import com.lordofduct.engines.physics.Arbiter;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.geom.Vector2;

	public class Phys2DCollisionResolver extends Arbiter
	{
		
		
		public function Phys2DCollisionResolver(b1:IPhysicalAttrib, b2:IPhysicalAttrib)
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
			
			var normal:Vector2 = this.collision.normal.clone();
			var penAxis:Vector2 = this.collision.penetrationAxis.clone();
			var depth:Number = this.collision.depth;
			var contacts:Array = this.getContacts(body1, body2, normal, penAxis, depth);
			
			var c1:Vector2 = body1.centerOfMass;
			var c2:Vector2 = body2.centerOfMass;
			var invM1:Number = body1.invMass;
			var invM2:Number = body2.invMass;
			var invI1:Number = body1.invInertiaTensor;
			var invI2:Number = body2.invInertiaTensor;
			var sim1:ISimulatableAttrib = body1 as ISimulatableAttrib
			var sim2:ISimulatableAttrib = body2 as ISimulatableAttrib
			
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
				if(sim1)
				{
					velAtCon1.copy(contactPerp1);
					velAtCon1.multiply(sim1.angularVelocity);
					velAtCon1.add( sim1.velocity );
				}
				var velAtCon2:Vector2 = new Vector2();
				if(sim2)
				{
					velAtCon2.copy(contactPerp2);
					velAtCon2.multiply(sim2.angularVelocity);
					velAtCon2.add(sim2.velocity);
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
				
				if(sim1 && sim1.isDynamicMass)
				{
					sim1.velocity.add( dlv1 );
					sim1.angularVelocity += dav1;
				}
				if(sim2 && sim2.isDynamicMass)
				{
					sim2.velocity.add( dlv2 );
					sim2.angularVelocity += dav2;
				}
			}
			
			super.applyImpulse();
		}
		
		private function getContacts(body1:IPhysicalAttrib, body2:IPhysicalAttrib, normal:Vector2, penAxis:Vector2, depth:Number ):Array
		{
			var axis:Vector2 = penAxis.clone();
			axis.multiply(depth);
			
			var b1inv:Number = body1.invMass;
			var b2inv:Number = body2.invMass;
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
			if(contacts1.length == 1) return contacts1[0];
			
			axis.negate();
			var contacts2:Array = body2.collisionMesh.findNearestContacts(axis, body2.physicalTransform.matrix);
			
			//if only one contact point, then that is it
			if(contacts2.length == 1) return contacts2[0];
			
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
			
			var arr:Array = [ cp[ projections[ 1 ] ], cp[ projections[ 2 ] ] ];
			return arr;
		}
	}
}