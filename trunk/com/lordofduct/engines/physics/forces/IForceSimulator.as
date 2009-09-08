package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	
	public interface IForceSimulator
	{
		function simulate( body:ISimulatableAttrib ):void
		function constrain( body:ISimulatableAttrib ):void
	}
}