package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	
	public class SimpleForce implements IForceSimulator
	{
		private var _force:Vector2;
		
		public function SimpleForce( forceY:Number=0, forceX:Number=0 )
		{
			_force = new Vector2(gravX, gravY);
		}
		
/**
 * Properties
 */
		public function get force():Vector2 { return _force; }
		public function set force(value:Vector2):void
		{
			_force = (value) ? value : new Vector2();
		}
		
/**
 * Methods
 */
	/**
	 * IForceSimulator interface
	 */
		public function simulate( body:ISimulatableAttrib ):void
		{
			body.forces.add(_force);
		}
		
		public function constrain( body:ISimulatableAttrib ):void
		{
			
		}
	}
}