package com.lordofduct.engines.physics.integrals
{
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	
	public interface IKinematicIntegral
	{
		function step(dt:Number, body:ISimulatableAttrib, globalForces:Array=null):void
		function integrateKinematicBody(dt:Number, body:ISimulatableAttrib, deriv:Derivative):void
		function getKinematicDerivativeOf(body:ISimulatableAttrib, globalForces:Array=null):Derivative
	}
}