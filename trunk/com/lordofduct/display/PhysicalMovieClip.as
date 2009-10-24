/**
 * PhysicalMovieClip - written by Dylan Engelman a.k.a LordOfDuct
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
 * 
 * 
 * For effinciency and memory purposes, PhysicalSprite implements IPhysicalAttrib
 * on its own terms. This doesn't mean one shouldn't use the PhysicalAttributes class 
 * when implementing IPhysicalAttrib, it just means that I the author decided to do it 
 * this way. The main reason it implements on its own terms is because it defaults to 
 * utilizing a SyncingLdTransform for the physicalTransform. This way the PhysicalSprite 
 * updates its transform matrix automatically with no need for extra code from you the user.
 * 
 * WARNING - AUTHOR DOES NOT LIKE THIS CLASS!
 * 
 * This class extends MovieClip and not LdTranSprite in any way. There is no simple way to extend LdTranSprite 
 * which would emulate the same hierarchy as the Flash DisplayObject hierarchy. 
 * 
 * I also dislike the whole idea because I personally find the MovieClip object to be a bloated and partially 
 * useless class except under certain stringant scenarios. I suggest utilizing the LdTranSprite family of objects 
 * as opposed to the MovieClip family unless you definately require MovieClip options (i.e. a timeline).
 * 
 * This MovieClip alternative merely exists for those of you who just can't live with out the MovieClip object type.
 */
package com.lordofduct.display
{
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.geom.LdTransform;
	import com.lordofduct.geom.SyncingLdTransform;
	import com.lordofduct.geom.SyncingTransform;
	import com.lordofduct.geom.Vector2;
	
	import flash.display.DisplayObject;

	public class PhysicalMovieClip extends LdTranMovieClip implements IPhysicalAttrib
	{
		private var _view:DisplayObject;
		
		private var _mesh:ICollisionMesh = null;
		
		private var _isRigBody:Boolean = false;
		
		protected var _mass:Number = 1;
		private var _invMass:Number = 1;
		private var _inertiaTensor:Number = 1;
		private var _invInertiaTensor:Number = 1;
		private var _elast:Number = 0;
		private var _frict:Number = 0;
		
		public function PhysicalMovieClip()
		{
			super();
			
			
		}
		
/**
 * Properties
 */
	/**
	 * IVisibleObject Interface
	 */
		public function get view():DisplayObject { return this; }
	/**
	 * IPhysicalAttrib Interface
	 */
		public function get physicalTransform():LdTransform { return _trans; }
		public function set physicalTransform(value:LdTransform):void { _trans = new SyncingLdTransform( value.matrix, this.transform as SyncingTransform ); }
		
		public function get collisionMesh():ICollisionMesh { return _mesh; }
		public function set collisionMesh(value:ICollisionMesh):void { _mesh = value; }
		
		public function get isRigidBody():Boolean { return _isRigBody; }
		public function set isRigidBody(value:Boolean):void { _isRigBody = value; }
		
		public function get mass():Number { return _mass; }
		public function set mass(value:Number):void { _mass = value; }
		
		public function get invMass():Number { return 0; }
		
		public function get inertiaTensor():Number { return _mass; }
		public function get invInertiaTensor():Number { return 0; }
		
		public function get centerOfMass():Vector2
		{
			if(!_mesh) return new Vector2(_trans.x, _trans.y);
			
			return _mesh.getCenterOfMass(_trans.matrix);
		}
		
		public function get elasticity():Number { return _elast; }
		public function set elasticity(value:Number):void { _elast = value; }
		
		public function get friction():Number { return _frict; }
		public function set friction(value:Number):void { _frict = value; }
		
/**
 * Methods
 */
	}
}