package com.lordofduct.engines.physics.collisionMesh
{
	import com.lordofduct.engines.physics.collisionDetectors.ICollisionDetector;
	import com.lordofduct.geom.Interval;
	import com.lordofduct.geom.Ray2D;
	import com.lordofduct.geom.Vector2;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public interface ICollisionMesh
	{
		function get boundingRect():Rectangle
		function get collisionDetector():ICollisionDetector
		function set collisionDetector(value:ICollisionDetector):void
		function get tensorLength():Number
		
		function getCenterOfMass(mat:Matrix=null):Vector2
		
		function invalidate():void
		
		function getAxes(mat:Matrix=null):Array
		function getAxesNorms(mat:Matrix=null):Array
		function projectOntoAxis(axis:Vector2, mat:Matrix=null):Interval
		function findNearestContacts(axis:Vector2, mat:Matrix=null):Array
		
		function castRayThrough(ray:Ray2D, mat:Matrix=null, dist:Number=NaN, epsilon:Number=0.0001):Array
	}
}