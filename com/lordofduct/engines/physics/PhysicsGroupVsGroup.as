package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.util.Assertions;
	
	public class PhysicsGroupVsGroup implements IPhysicsCollection
	{
		private var _alg:ICollisionResolver;
		
		private var _colInternal:Boolean = false;
		private var _stepsInternal:Boolean = false;
		private var _resInternal:Boolean = false;
		
		private var _damping:Number = 1;
		
		private var _groups:Array = new Array();
		private var _simulators:Array = new Array();
		
		public function PhysicsGroupVsGroup(alg:ICollisionResolver=null)
		{
			_alg = alg;
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
		public function addGroup( group:IPhysicsCollection ):void
		{
			if(!this.containsGroup( group )) _groups.push(group);
		}
		
		public function removeGroup( group:IPhysicsCollection ):void
		{
			if(!this.containsGroup(group)) return;
			
			var index:int = _groups.indexOf(group);
			_groups.splice(index,1);
		}
		
		public function containsGroup( group:IPhysicsCollection ):Boolean
		{
			Assertions.notNil( group, "com.lordofduct.engines.physics::PhysicsGroup - can not validate a null instance" );
			
			return Boolean( _groups.indexOf( group ) >= 0 );
		}
		
		public function getGroupList():Array
		{
			return _groups.slice();
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
			if(!this.stepsInternal) return;
			
			includedForces = (includedForces) ? includedForces.concat(_simulators) : _simulators.slice();
			
			for each( var group:IPhysicsCollection in _groups )
			{
				group.step(dt, includedForces);
			}
		}
		
		public function collide():void
		{
			if(!this.collidesInternal) return;
			
			var temp:Array = this.getGroupList();
			
			while(temp.length)
			{
				var group:IPhysicsCollection = temp.pop() as IPhysicsCollection;
				
				for each( var other:IPhysicsCollection in temp )
				{
					group.collideAgainst(other, _resInternal, _alg);
				}
			}
		}
		
		public function collideAgainst(value:*, resolve:Boolean=true, resAlg:ICollisionResolver=null ):void
		{
			if(!resAlg) resAlg = _alg;
			
			for each( var group:IPhysicsCollection in _groups )
			{
				group.collideAgainst(value, resolve, resAlg);
			}
		}
	}
}