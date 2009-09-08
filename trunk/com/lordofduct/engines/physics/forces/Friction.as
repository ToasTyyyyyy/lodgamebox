package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;

	public class Friction implements IForceSimulator
	{
		private var _frict:Number=0;
		
		public function Friction(frict:Number=0.1)
		{
			_frict = LoDMath.clamp( frict, 1 );
		}
		
		public function get friction():Number { return _frict; }
		public function set friction(value:Number):void { _frict = LoDMath.clamp(value, 1); }

		public function simulate(body:ISimulatableAttrib):void
		{
			var vel:Vector2 = body.velocity.clone();
			vel.negate();
			vel.multiply(body.mass * _frict);
			body.forces.add( vel );
			body.torque += -body.angularVelocity * _frict * body.inertiaTensor;
		}
		
		public function constrain(body:ISimulatableAttrib):void
		{
			//do nothing
		}
		
	}
}