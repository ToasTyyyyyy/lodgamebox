package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.util.Assertions;
	
	public class PhysicsCollection implements IPhysicsCollection
	{
		private var _arb:Class;
		
		private var _colInternal:Boolean = false;
		private var _stepsInternal:Boolean = false;
		private var _resInternal:Boolean = false;
		
		private var _bodies:Array = new Array();
		private var _simulators:Array = new Array();
		private var _arbiterList:ArbiterList = new ArbiterList();
		
		public function PhysicsCollection(arbiter:Class=null, steps:Boolean=true, collides:Boolean=true, resolves:Boolean=true)
		{
			_arb = (arbiter) ? arbiter : Arbiter;
			_stepsInternal = steps;
			_colInternal = collides;
			_resInternal = resolves;
		}
/**
 * Properties
 */	
		public function get collidesInternal():Boolean { return _colInternal; }
		public function set collidesInternal(value:Boolean):void { _colInternal = value; }
		
		public function get stepsInternal():Boolean { return _stepsInternal; }
		public function set stepsInternal(value:Boolean):void { _stepsInternal = value; }
		
		public function get resolvesInternal():Boolean { return _resInternal; }
		public function set resolvesInternal(value:Boolean):void { _resInternal = value; }
		
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
			
			var arr:Array = _arbiterList.arbiterExistsFor( body );
			
			for each( var arb:Arbiter in arr )
			{
				_arbiterList.remove( arb );
			}
		}
		
		public function containsPhysicalBody( body:IPhysicalAttrib ):Boolean
		{
			Assertions.notNil( body, "com.lordofduct.engines.physics::PhysicsGroup - can not validate a null instance" );
			
			return Boolean( _bodies.indexOf( body ) >= 0 );
		}
		
	/**
	 * IPhysicsCollection methods Interface
	 */
		public function getPhysicalBodyList():Array
		{
			return _bodies.slice();
		}
		
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
			//resolve arbiters
			var i:int;
			
			//TODO - check if resolves internal
			if(this.resolvesInternal)
			{
				var al:int = _arbiterList.length, arbiter:Arbiter;
				var invDt:Number = (dt > 0) ? 1 / dt : 0;
				
				for(i = 0; i < al; i++)
				{
					arbiter = _arbiterList.getItem(i);
					
					arbiter.preStep( invDt, dt );
					arbiter.applyImpulse();
				}
			}
			
			if(!_stepsInternal) return;
			//update positions
			includedForces = (includedForces) ? includedForces.concat(_simulators) : _simulators.slice();
			
			var body:ISimulatableAttrib, subForces:Array, force:IForceSimulator;
			
			for (i = 0; i < _bodies.length; i++)
			{
				body = _bodies[i] as ISimulatableAttrib;
				if(body && body.isDynamicMass)
				{
					body.kinematicIntegrator.step(dt, body as ISimulatableAttrib, includedForces);
					
					subForces = includedForces.concat( body.getForceSimulators() );
					for each( force in subForces )
					{
						if(force) force.constrain(body);
					}
				}
			}
		}
		
		public function collide():void
		{
			if(!_colInternal) return;
			
			var coll:Array = this.getPhysicalBodyList();
			var body1:IPhysicalAttrib, body2:IPhysicalAttrib;
			
			while( coll.length )
			{
				body1 = coll.pop() as IPhysicalAttrib;
				
				for each( body2 in coll )
				{
					if(body1 == body2) continue;
					
					var arb:Arbiter = new _arb(body1, body2);
					var index:int = _arbiterList.indexOf(arb);
					if(index >= 0) arb.copy( _arbiterList.getItem(index) );
					
					var collision:Collision = (arb.collision) ? arb.collision : LoDPhysicsEngine.instance.constructCollisionChosen( body1, body2 );
					
					if(collision.collides())
					{
						arb.update(collision);
						_arbiterList.add(arb);
					} else _arbiterList.remove(arb);
				}
			}
		}
		
		
		public function collisionExistsFor( body:IPhysicalAttrib ):Boolean
		{
			var arr:Array = _arbiterList.arbiterExistsFor( body );
			
			return !(arr == null);
		}
		
		public function collisionsFor( body:IPhysicalAttrib ):Array
		{
			var arr:Array = _arbiterList.arbiterExistsFor( body );
			
			if(!arr) return null;
			
			var colls:Array = new Array();
			
			for ( var i:int = 0; i < arr.length; i++ )
			{
				var coll:Collision = arr[i] as Collision;
				if(coll) colls.push( coll );
			}
			
			return colls;
		}
	}
}