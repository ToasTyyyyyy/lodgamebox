package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.util.Assertions;
	
	public class PhysicsCollection implements IPhysicsCollection
	{
		private var _alg:ICollisionResolver;
		
		private var _colInternal:Boolean = false;
		private var _stepsInternal:Boolean = false;
		private var _resInternal:Boolean = false;
		
		private var _damping:Number = 1;
		
		private var _bodies:Array = new Array();
		private var _simulators:Array = new Array();
		
		public function PhysicsCollection(alg:ICollisionResolver=null, steps:Boolean=true, collides:Boolean=true, resolves:Boolean=true)
		{
			_alg = alg;
			_stepsInternal = steps;
			_colInternal = collides;
			_resInternal = resolves;
		}
/**
 * Properties
 */
		public function get collisionResolver():ICollisionResolver { return _alg; }
		public function set collisionResolver(value:ICollisionResolver):void
		{
			_alg = value;
		}
		
		public function get collidesInternal():Boolean { return _colInternal; }
		public function set collidesInternal(value:Boolean):void { _colInternal = value; }
		
		public function get stepsInternal():Boolean { return _stepsInternal; }
		public function set stepsInternal(value:Boolean):void { _stepsInternal = value; }
		
		public function get resolvesInternal():Boolean { return _resInternal; }
		public function set resolvesInternal(value:Boolean):void { _resInternal = value; }
		
		public function get damping():Number { return _damping; }
		public function set damping(value:Number):void { _damping = value; }
		
/**
 * Methods
 */
		public function addPhysicalBody( body:IPhysicalAttrib ):void
		{
			if(!this.containsPhysicalBody( body )) _bodies.push(body);
		}
		
		public function removePhysicalBody( body:IPhysicalAttrib ):void
		{
			if(!this.containsPhysicalBody(body)) return;
			
			var index:int = _bodies.indexOf(body);
			_bodies.splice(index,1);
		}
		
		public function containsPhysicalBody( body:IPhysicalAttrib ):Boolean
		{
			Assertions.notNil( body, "com.lordofduct.engines.physics::PhysicsGroup - can not validate a null instance" );
			
			return Boolean( _bodies.indexOf( body ) >= 0 );
		}
		
		public function getPhysicalBodyList():Array
		{
			return _bodies.slice();
		}
		
	/**
	 * IPhysicsCollection methods Interface
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
		
		public function step(dt:Number, includedForces:Array=null):void
		{
			if(!_stepsInternal) return;
			
			includedForces = (includedForces) ? includedForces.concat(_simulators) : _simulators.slice();
			
			var body:ISimulatableAttrib;
			
			for (var i:int = 0; i < _bodies.length; i++)
			{
				body = _bodies[i] as ISimulatableAttrib;
				if(body && body.isDynamicMass) (body as ISimulatableAttrib).kinematicIntegrator.step(dt, body as ISimulatableAttrib, includedForces);
			}
		}
		
		public function collide():void
		{
			if(!_colInternal) return;
			
			var coll:Array = this.getPhysicalBodyList();
			var phys:LoDPhysicsEngine = LoDPhysicsEngine.instance;
			
			while( coll.length )
			{
				var body:IPhysicalAttrib = coll.pop() as IPhysicalAttrib;
				
				for each( var other:IPhysicalAttrib in coll )
				{
					phys.testCollisionOf( body, other, _resInternal, _alg );
				}
			}
		}
		
		public function collideAgainst(value:*, resolve:Boolean=true, resAlg:ICollisionResolver=null ):void
		{
			if(!resAlg) resAlg = _alg;
			
			for each(var body:IPhysicalAttrib in _bodies)
			{
				if( value is IPhysicsCollection)
				{
					IPhysicsCollection(value).collideAgainst(body, resolve, resAlg);
				} else if( value is IPhysicalAttrib )
				{
					LoDPhysicsEngine.instance.testCollisionOf( body, value as IPhysicalAttrib, resolve, resAlg );
				}
			}
		}
		
		public function constrain(includedForces:Array=null):void
		{
			var forces:Array = _simulators.concat( includedForces );
			var bodies:Array = this.getPhysicalBodyList();
			var subForces:Array, sim:ISimulatableAttrib;
			
			for (var i:int = 0; i < bodies.length; i++)
			{
				sim = bodies[i] as ISimulatableAttrib;
				
				if(!sim) continue;
				
				subForces = forces.concat( sim.getForceSimulators() );
				
				for each( var force:IForceSimulator in subForces )
				{
					if(force) force.constrain(sim);
				}
			}
		}
	}
}