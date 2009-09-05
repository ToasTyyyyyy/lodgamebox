package com.lordofduct.engines.physics.collisionMesh
{
	public interface IPhasedCollisionMesh extends ICollisionMesh
	{
		function get totalPhases():int
		function get currentPhase():int
		function set currentPhase(value:int):void
	}
}