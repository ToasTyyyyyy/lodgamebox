package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.engines.physics.integrals.EulerKinematicIntegral;
	import com.lordofduct.engines.physics.integrals.IKinematicIntegral;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;
	import com.lordofduct.util.LoDMatrixTransformer;
	
	import flash.geom.Matrix;
	
	public class SimulatableAttributes extends PhysicalAttributes implements ISimulatableAttrib
	{
		private var _isDynMass:Boolean = false;
		
		private var _vel:Vector2 = new Vector2();
		private var _avel:Number = 0;
		private var _invMass:Number = 1;
		
		private var _simulators:Array = new Array();
		private var _forces:Vector2 = new Vector2();
		private var _torque:Number = 0;
		
		private var _integrator:IKinematicIntegral;
		
		public function SimulatableAttributes(target:IPhysicalAttrib=null, integrator:IKinematicIntegral=null)
		{
			super(target);
			
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