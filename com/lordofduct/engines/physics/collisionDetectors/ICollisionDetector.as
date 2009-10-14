package com.lordofduct.engines.physics.collisionDetectors
{
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	
	import flash.geom.Matrix;
	
	public interface ICollisionDetector
	{
		function get weight():Number
		
		function testBodyBody( body1:IPhysicalAttrib, body2:IPhysicalAttrib ):*
		function testAbstractMesh( mesh1:ICollisionMesh, mesh2:ICollisionMesh, mat1:Matrix=null, mat2:Matrix=null ):CollisionResult
	}
}