/**
 * BoundingBoxCollisionDetector - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * Copyright (c) 2009 Dylan Engelman
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, 
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject to the following 
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies 
 * or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * 
 * In other words, no guarantees are made that it will work as expected nor that I (Dylan Engelman) 
 * have to repair or give any assistance to you the user when you have troubles.
 * 
 */
package com.lordofduct.engines.physics.collisionDetectors
{
	import com.lordofduct.engines.physics.CollisionResult;
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.LoDPhysicsEngine;
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	import com.lordofduct.events.PhysicsEvent;
	import com.lordofduct.geom.Interval;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	final public class AABBCollisionDetector implements ICollisionDetector
	{
		private static var _inst:AABBCollisionDetector;
		
		public static function get instance():AABBCollisionDetector
		{
			if (!_inst) _inst = SingletonEnforcer.gi(AABBCollisionDetector);
			
			return _inst;
		}
		
		public function AABBCollisionDetector()
		{
			SingletonEnforcer.assertSingle(AABBCollisionDetector);
		}
		
/**
 * Class Definition
 */
		public function get weight():Number { return 0; }
		
		public function testBodyBody( body1:IPhysicalAttrib, body2:IPhysicalAttrib, resolve:Boolean=false, resAlg:ICollisionResolver=null ):*
		{
			if(!body1 || !body2) return null;
			
			var res:CollisionResult = testAbstractMesh( body1.collisionMesh, body2.collisionMesh, body1.physicalTransform.matrix, body2.physicalTransform.matrix );
			if(res)
			{
				res.body1 = body1;
				res.body2 = body2;
			}
			
			LoDPhysicsEngine.instance.poolCollisionResult( res, resolve, resAlg );
			
			return res;
		}
		
		/**
		 * tests the bounding boxes of two CollisionMesh objects. Upong overlap a CollisionResult is returned.
		 */
		public function testAbstractMesh( mesh1:ICollisionMesh, mesh2:ICollisionMesh, mat1:Matrix=null, mat2:Matrix=null ):CollisionResult
		{	
			if(!mesh1 || !mesh2) return null;
			
			var rect1:Rectangle = mesh1.boundingRect;
			var rect2:Rectangle = mesh2.boundingRect;
			if(!rect1 || !rect2) return null;
			if(!mat1) mat1 = new Matrix();
			if(!mat2) mat2 = new Matrix();
			
			rect1 = LoDMath.transformRectByMatrix( rect1, mat1 );
			rect2 = LoDMath.transformRectByMatrix( rect2, mat2 );
			return tessAABBvsAABB( rect1, rect2 );
		}
		
		public function tessAABBvsAABB( rect1:Rectangle, rect2:Rectangle ):CollisionResult
		{
			var inter:Rectangle = rect1.intersection(rect2);
			
			if(!(inter.width > 0 && inter.height > 0)) return null;
			
			var penAxis:Vector2, normal:Vector2;
			var depth:Number = (inter.width > inter.height) ? inter.height : inter.width;
			var olaps:Array = [ new Interval( inter.top, inter.bottom, Vector2.UnitY ), new Interval( inter.left, inter.right, Vector2.UnitX ) ];
			
			if(inter.width > inter.height)
			{
				penAxis = Vector2.UnitY;
				if( rect1.top < rect2.top ) penAxis.negate();
			} else {
				penAxis = Vector2.UnitX;
				if( rect1.left > rect2.left ) penAxis.negate();
			}
			
			normal = Vector2.normal(penAxis);
			return new CollisionResult( penAxis, normal, depth, olaps );
		}
	}
}