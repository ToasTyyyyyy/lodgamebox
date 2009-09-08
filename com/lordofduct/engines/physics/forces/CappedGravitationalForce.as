package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	
	public class CappedGravitationalForce extends GravitationalForce
	{
		private var _cap:Number;
		
		public function CappedGravitationalForce(gravY:Number=9.8, gravX:Number=0, cap:Number=NaN)
		{
			super(gravY, gravX);
			
			this.speedCap = cap;
		}
		
		public function get speedCap():Number { return _cap; }
		public function set speedCap(value:Number):void { _cap = (isNaN(value)) ? Number.POSITIVE_INFINITY : value; }
		
		override public function constrain(body:ISimulatableAttrib):void
		{	
			if(_cap == Number.POSITIVE_INFINITY) return;
			
			var dir:Vector2 = Vector2.normalize(gravity);
			var dot:Number = body.velocity.dot( dir );
			
			if( dot > _cap )
			{
				var vel:Vector2 = body.velocity;
				//set vel length so that when projected on gravity unit vector you get _cap
				vel.length = _cap * vel.length / (vel.x * dir.x + vel.y * dir.y);
				body.velocity = vel;
			}
		}
	}
}