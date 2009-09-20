/**
 * SimulatableMovieClip - written by Dylan Engelman a.k.a LordOfDuct
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
 * For effinciency and memory purposes, PhysicalSprite implements ISimulatableAttrib
 * on its own terms. This doesn't mean one shouldn't use the SimulatableAttributes class 
 * when implementing ISimulatableAttrib, it just means that I the author decided to do it 
 * this way to allow for more efficiency in the extension chain where SimulatableSprite extends 
 * PhysicalSprite.
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
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.engines.physics.integrals.EulerKinematicIntegral;
	import com.lordofduct.engines.physics.integrals.IKinematicIntegral;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;
	import com.lordofduct.util.LoDMatrixTransformer;
	
	import flash.geom.Matrix;

	public class SimulatableMovieClip extends PhysicalMovieClip implements ISimulatableAttrib
	{
		private var _isDynMass:Boolean = false;
		
		private var _vel:Vector2 = new Vector2();
		private var _avel:Number = 0;
		private var _invMass:Number = 1;
		
		private var _simulators:Array = new Array();
		private var _forces:Vector2 = new Vector2();
		private var _torque:Number = 0;
		
		private var _integrator:IKinematicIntegral;
		
		public function SimulatableMovieClip(integrator:IKinematicIntegral=null)
		{
			super();
			
			_integrator = (integrator) ? integrator : EulerKinematicIntegral.instance;
		}
		
/**
 * Properties
 */
	/**
	 * ISimulatable Interface
	 */
		override public function set mass(value:Number):void
		{
			super.mass = value;
			
			if(value == Number.POSITIVE_INFINITY) _invMass = 0;
			else _invMass = 1 / value;
		}
		
		override public function get invMass():Number { return (_isDynMass) ? _invMass : 0; }
		override public function get inertiaTensor():Number
		{
			if(!_isDynMass || !collisionMesh) return Number.POSITIVE_INFINITY;
			
			var m:Matrix = _trans.matrix;
			return collisionMesh.tensorLength * this.mass * LoDMath.average( LoDMatrixTransformer.getScaleX(m), LoDMatrixTransformer.getScaleY(m) );
		}
		override public function get invInertiaTensor():Number
		{
			var I:Number = this.inertiaTensor;
			return (I != Number.POSITIVE_INFINITY) ? 1 / I : 0;
		}
		
		public function get isDynamicMass():Boolean { return _isDynMass; }
		public function set isDynamicMass(value:Boolean):void { _isDynMass = value; }
		
		public function get velocity():Vector2
		{
			return _vel;
		}
		public function set velocity(value:Vector2):void
		{
			_vel = (value) ? value : new Vector2();
		}
		
		public function get angularVelocity():Number
		{
			return _avel;
		}
		public function set angularVelocity(value:Number):void
		{
			_avel = value;
		}
		
		public function get forces():Vector2 { return _forces; }
		public function set forces(value:Vector2):void
		{
			_forces = (value) ? value : new Vector2();
		}
		
		public function get torque():Number { return _torque; }
		public function set torque(value:Number):void
		{
			_torque = value;
		}
		
		public function get kinematicIntegrator():IKinematicIntegral
		{
			return _integrator;
		}
		
/**
 * Methods
 */
	/**
	 * ISimulatable Interface
	 */
		public function getForceSimulators():Array
		{
			return _simulators.slice();
		}
		
		public function addForceSimulator(force:IForceSimulator):void
		{
			if(!force) return;
			
			if(_simulators.indexOf(force >= 0)) removeForceSimulator(force);
			_simulators.push(force);
		}
		
		public function removeForceSimulator(force:IForceSimulator):void
		{
			if(!force) return;
			
			var index:int = _simulators.indexOf(force);
			if(index >= 0) _simulators.splice(index,1);
		}
		
		public function removeAllForceSimulators():void
		{
			_simulators.length = 0;
		}
	}
}