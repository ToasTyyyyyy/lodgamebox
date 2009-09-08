package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;

	public class PivotPointLock implements IForceSimulator
	{
		private var _pos:Vector2;
		private var _frict:Number;
		
		public function PivotPointLock(pos:*, frict:Number=0)
		{
			_pos = Vector2.copy(pos);
			_frict = LoDMath.clamp( frict, 1 );
		}
		
		public function get position():Vector2 { return _pos; }
		public function set position(value:Vector2):void { _pos.copy(value); }
		
		public function get friction():Number { return _frict; }
		public function set friction(value:Number):void { _frict = LoDMath.clamp( value, 1 ); }

		public function simulate(body:ISimulatableAttrib):void
		{
			body.forces.add(Vector2.NAN);
		}
		
		public function constrain( body:ISimulatableAttrib ):void
		{
			body.physicalTransform.x = _pos.x;
			body.physicalTransform.y = _pos.y;
			body.velocity.setTo();
			body.angularVelocity *= (1 - _frict);
		}
	}
}