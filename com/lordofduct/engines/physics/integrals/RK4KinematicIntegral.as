package com.lordofduct.engines.physics.integrals
{
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.util.SingletonEnforcer;

	public class RK4KinematicIntegral implements IKinematicIntegral
	{
		private static var _inst:RK4KinematicIntegral;
		
		public static function get instance():RK4KinematicIntegral
		{
			if (!_inst) _inst = SingletonEnforcer.gi(RK4KinematicIntegral);
			
			return _inst;
		}
		
		public function RK4KinematicIntegral()
		{
			SingletonEnforcer.assertSingle(RK4KinematicIntegral);
		}
/**
 * Class Definition
 */
		public function step(dt:Number, body:IPhysicalAttrib, globalForces:Array=null):void
		{
			var deriv:Derivative = this.getKinematicDerivativeOf(body, globalForces);
			this.integrateKinematicBody(dt, body, deriv);
		}
		
		public function integrateKinematicBody(dt:Number, body:IPhysicalAttrib, deriv:Derivative):void
		{
			
		}
		
		public function getKinematicDerivativeOf(body:IPhysicalAttrib, globalForces:Array=null):Derivative
		{
			var der:Derivative = new Derivative();
			der.velA = body.angularVelocity;
			der.velX = body.velocity.x;
			der.velY = body.velocity.y;
			
			//must solve forces
			globalForces = (globalForces) ? globalForces.concat(body.getForceSimulators()) : body.getForceSimulators();
			
			for each(var force:IForce in globalForces)
			{
				force.simulate(body);
			}
			
			//solve accelerations
			der.accA = body.torque * body.invInertiaTensor;
			der.accX = body.velocity.x * body.invMass;
			der.accY = body.velocity.y * body.invMass;
			
			body.forces.setTo(0,0);
			body.torque = 0;
			
			return der;
		}
		
	}
}