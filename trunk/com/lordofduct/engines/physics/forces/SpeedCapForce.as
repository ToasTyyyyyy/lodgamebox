package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;

	public class SpeedCapForce implements IForceSimulator
	{
		private var _cap:Number;
		private var _acap:Number;
		
		public function SpeedCapForce(cap:Number=NaN, angularCap:Number=NaN)
		{
			this.speedCap = cap;
			this.angularSpeedCap = angularCap;
		}
		
		public function get speedCap():Number { return _cap; }
		public function set speedCap(value:Number):void { _cap = (isNaN(value)) ? Number.POSITIVE_INFINITY : value; }
		
		public function get angularSpeedCap():Number { return _acap; }
		public function set angularSpeedCap(value:Number):void { _acap = (isNaN(value)) ? Number.POSITIVE_INFINITY : value; }

		public function simulate(body:ISimulatableAttrib):void
		{
			//do nothing
		}
		
		public function constrain(body:ISimulatableAttrib):void
		{
			if(body.velocity.length > _cap)
			{
				var vel:Vector2 = body.velocity;
				vel.length = _cap;
				body.velocity = vel;
			}
			
			if(Math.abs(body.angularVelocity) > Math.abs(_acap))
			{
				body.angularVelocity = LoDMath.sign(body.angularVelocity) * _acap;
			}
		}
		
	}
}