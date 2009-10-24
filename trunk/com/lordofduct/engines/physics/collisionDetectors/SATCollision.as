package com.lordofduct.engines.physics.collisionDetectors
{
	import com.lordofduct.engines.physics.Collision;
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.LoDPhysicsEngine;
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.geom.Interval;
	import com.lordofduct.geom.Vector2;
	
	import flash.geom.Matrix;

	public class SATCollision extends Collision
	{
		public function SATCollision(b1:IPhysicalAttrib, b2:IPhysicalAttrib)
		{
			super(b1, b2, 2);
		}
		
		override public function collides():Boolean
		{
			var res:CollisionResult = SATCollision.testBodyBody( this.body1, this.body2 );
			if(!res) return false;
			
			this.updateByCollisionResult( res );
			
			return true;
		}
		
		override public function getContacts():Array
		{
			return null;
		}
/**
 * STATIC INTERFACE
 */
		public function testBodyBody( body1:IPhysicalAttrib, body2:IPhysicalAttrib ):*
		{
			if(!body1 || !body2) return null;
			
			var res:CollisionResult = testAbstractMesh( body1.collisionMesh, body2.collisionMesh, body1.physicalTransform.matrix, body2.physicalTransform.matrix );
			if(res)
			{
				res.body1 = body1;
				res.body2 = body2;
			}
			
			LoDPhysicsEngine.instance.poolCollisionResult( res );
			
			return res;
		}
		
		/**
		 * Tests two CollisionMeshs via the Seperating Axis Theorem.
		 * 
		 * If the either CollisionMesh supplied does not meet the requirements of SAT collision, for which they do 
		 * not contain any IGeometricShape data, then an OBB of that CollisionMesh will be constructed and used instead. 
		 */
		public function testAbstractMesh( mesh1:ICollisionMesh, mesh2:ICollisionMesh, mat1:Matrix=null, mat2:Matrix=null ):CollisionResult
		{	
			if(!mesh1 || !mesh2) return null;
			
			//var res:CollisionResult = AABBCollisionDetector.instance.testAbstractMesh(mesh1, mesh2, mat1, mat2);
			//if(!res) return null;
			
			var g1inter:Interval, g2inter:Interval, overlap:Interval, axis:Vector2, c1:Vector2, c2:Vector2;
			//first let's throw out the idea that the central axis could be the separating axis
			//this is our first quick draw... if two objects are no where near each other then 
			//this axis most certainly doesn't overlap
			c1 = mesh1.getCenterOfMass(mat1);
			c2 = mesh2.getCenterOfMass(mat2);
			axis = Vector2.subtract(c2, c1);
			
			if(!axis.length)
			{
				axis = Vector2.UnitX;
				g1inter = mesh1.projectOntoAxis(axis, mat1);
				g2inter = mesh2.projectOntoAxis(axis, mat2);
				overlap = g1inter.intervalIntersection(g2inter);
				axis;
				return new CollisionResult(axis, Vector2.normal(axis), overlap.intervalLength);
			}
			
			axis.normalize();
			
			var axes:Array = [axis];
			axes = axes.concat( mesh1.getAxes(mat1) );
			axes = axes.concat( mesh2.getAxes(mat2) );
			var ile:int = axes.length;
			//removeParallelAxes(axes);
			
			var penAxis:Vector2 = new Vector2();
			var dep:Number = Number.POSITIVE_INFINITY;
			for(var i:int = 0; i < axes.length; i++)
			{
				axis = axes[i] as Vector2;
				g1inter = mesh1.projectOntoAxis(axis, mat1);
				g2inter = mesh2.projectOntoAxis(axis, mat2);
				overlap = g1inter.intervalIntersection(g2inter);
				
				//if it didn't overlap then no collision occured, stop now
				if(!overlap) return null;
				
				if(overlap.intervalLength < dep)
				{
					dep = overlap.intervalLength;
					penAxis.copy(axis);
				}
			}
			
			//COLLISION OCCURED, return data
			var normal:Vector2 = Vector2.normal(penAxis);
			return new CollisionResult(penAxis, normal, dep);
		}
		
		private function removeParallelAxes(arr:Array):void
		{
			var axis1:Vector2, axis2:Vector2, i:int, bool:Boolean;
			
			for (i = 0; i < arr.length; i++)
			{
				axis1 = arr.shift() as Vector2;
				bool = false;
				
				for each( axis2 in arr )
				{
					if(axis1.fuzzyEquals(axis2, 0.001)) bool = true;
				}
				
				if(!bool)
				{
					arr.push(axis1);
				}
			}
		}
	}
}