package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;

	public class VelocityCapForce extends SpeedCapForce implements IForceSimulator
	{
		private var _dir:Vector2;
		
		public function VelocityCapForce(dir:Vector2, cap:Number=NaN)
		{
			super(cap);
			_dir = Vector2.normalize(dir);
		}
		
		public function get capDirection():Vector2 { return _dir.clone(); }
		public function set capDirection(value:*):void { _dir.copy(value); _dir.normalize(); }
		
		override public function constrain(body:ISimulatableAttrib):void
		{
			var dot:Number = _dir.dot( body.velocity );
			
			if(dot > this.speedCap)
			{
				var vel:Vector2 = body.velocity;
				//set vel length so that when projected on _dir you get _cap
				vel.length = this.speedCap * vel.length / (vel.x * _dir.x + vel.y * _dir.y);
				body.velocity = vel;
			}
			
			if(Math.abs(body.angularVelocity) > Math.abs(this.angularSpeedCap))
			{
				body.angularVelocity = LoDMath.sign(body.angularVelocity) * this.angularSpeedCap;
			}
		}
		
	}
}