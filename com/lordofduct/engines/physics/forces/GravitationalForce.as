package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	
	public class GravitationalForce implements IForceSimulator
	{
		private var _grav:Vector2;
		
		public function GravitationalForce( gravY:Number=9.8, gravX:Number=0 )
		{
			_grav = new Vector2(gravX, gravY);
		}
		
/**
 * Properties
 */
		public function get gravity():Vector2 { return _grav; }
		public function set gravity(value:Vector2):void
		{
			_grav = (value) ? value : new Vector2();
		}
		
/**
 * Methods
 */
	/**
	 * IForceSimulator interface
	 */
		public function simulate( body:ISimulatableAttrib ):void
		{
			body.forces.add(Vector2.multiply(_grav, body.mass));
		}
		
		public function constrain( body:ISimulatableAttrib ):void
		{
			
		}
	}
}