package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.geom.LdTransform;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.ITransformable;
	import com.lordofduct.util.IVisibleObject;
	
	public interface IPhysicalAttrib extends IEventDispatcher, IVisibleObject, ITransformable
	{
		function get physicalTransform():LdTransform
		function set physicalTransform(value:LdTransform):void
		
		function get collisionMesh():ICollisionMesh
		function set collisionMesh(value:ICollisionMesh):void
		
		function get isRigidBody():Boolean
		function set isRigidBody(value:Boolean):void
		
		function get mass():Number
		function set mass(value:Number):void
		
		function get invMass():Number
		
		function get inertiaTensor():Number
		
		function get invInertiaTensor():Number
		
		function get centerOfMass():Vector2
		
		function get elasticity():Number
		function set elasticity(value:Number):void
		
		function get friction():Number
		function set friction(value:Number):void
		
		
/**
 * Methods
 */
		function getPhysicalBounds():Rectangle
	}
}