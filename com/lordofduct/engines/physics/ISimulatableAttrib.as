package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.engines.physics.integrals.IKinematicIntegral;
	import com.lordofduct.geom.Vector2;
	
	public interface ISimulatableAttrib extends IPhysicalAttrib
	{
		function get isDynamicMass():Boolean
		function set isDynamicMass(value:Boolean):void
		
		function get velocity():Vector2
		function set velocity(value:Vector2):void
		
		function get angularVelocity():Number
		function set angularVelocity(value:Number):void
		
		function get forces():Vector2
		function set forces(value:Vector2):void
		
		function get torque():Number
		function set torque(value:Number):void
		
		function get kinematicIntegrator():IKinematicIntegral
		
		function getForceSimulators():Array
		function addForceSimulator(force:IForceSimulator):void
		function removeForceSimulator(force:IForceSimulator):void
		function removeAllForceSimulators():void
	}
}