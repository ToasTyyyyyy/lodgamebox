package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	
	public interface IPhysicsCollection
	{
		function get collidesInternal():Boolean
		function set collidesInternal(value:Boolean):void
		
		function get stepsInternal():Boolean
		function set stepsInternal(value:Boolean):void
		
		function get resolvesInternal():Boolean
		function set resolvesInternal(value:Boolean):void
		
		function getPhysicalBodyList():Array
		function getForceSimulators():Array
		function addForceSimulator(force:IForceSimulator):void
		function removeForceSimulator(force:IForceSimulator):void
		function removeAllForceSimulators():void
		
		function step(dt:Number, includedForces:Array=null):void
		function collide():void
	}
}