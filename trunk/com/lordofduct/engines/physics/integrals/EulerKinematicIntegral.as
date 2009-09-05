package com.lordofduct.engines.physics.integrals
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.events.PhysicsEvent;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.SingletonEnforcer;

	public class EulerKinematicIntegral implements IKinematicIntegral
	{
		private static var _inst:EulerKinematicIntegral;
		
		public static function get instance():EulerKinematicIntegral
		{
			if (!_inst) _inst = SingletonEnforcer.gi(EulerKinematicIntegral);
			
			return _inst;
		}
		
		public function EulerKinematicIntegral()
		{
			SingletonEnforcer.assertSingle(EulerKinematicIntegral);
		}
/**
 * Class Definition
 */
		public function step(dt:Number, body:ISimulatableAttrib, globalForces:Array=null):void
		{
			var deriv:Derivative = this.getKinematicDerivativeOf(body, globalForces);
			this.integrateKinematicBody(dt, body, deriv);
		}
		
		public function integrateKinematicBody(dt:Number, body:ISimulatableAttrib, deriv:Derivative):void
		{	
			body.physicalTransform.x += deriv.velX * dt;
			body.physicalTransform.y += deriv.velY * dt;
			body.physicalTransform.rotate( deriv.velA * dt );
			
			var vel:Vector2 = body.velocity;
			vel.x += deriv.accX * dt;
			vel.y += deriv.accY * dt;
			body.velocity = vel;
			body.angularVelocity += deriv.accA * dt;
			
			body.dispatchEvent( new PhysicsEvent( PhysicsEvent.BODY_MOVED ) );
		}
		
		public function getKinematicDerivativeOf(body:ISimulatableAttrib, globalForces:Array=null):Derivative
		{
			var der:Derivative = new Derivative();
			der.velA = body.angularVelocity;
			der.velX = body.velocity.x;
			der.velY = body.velocity.y;
			
			//must solve forces
			globalForces = (globalForces) ? globalForces.concat(body.getForceSimulators()) : body.getForceSimulators();
			
			for each(var force:IForceSimulator in globalForces)
			{
				force.simulate(body);
			}
			
			//solve accelerations
			der.accA = body.torque * body.invInertiaTensor;
			der.accX = body.forces.x * body.invMass;
			der.accY = body.forces.y * body.invMass;
			
			//reset forces
			body.forces.setTo(0,0);
			body.torque = 0;
			
			return der;
		}
	}
}