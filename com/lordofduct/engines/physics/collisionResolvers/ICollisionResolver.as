package com.lordofduct.engines.physics.collisionResolvers
{
	import com.lordofduct.engines.physics.CollisionResult;
	
	public interface ICollisionResolver
	{
		function resolveCollisionPool( pool:Array ):void
		function resolveCollision( result:CollisionResult ):void
	}
}