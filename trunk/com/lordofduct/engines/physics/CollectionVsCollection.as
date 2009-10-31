package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.forces.IForceSimulator;
	import com.lordofduct.util.Assertions;

	public class CollectionVsCollection implements IPhysicsCollection
	{
		private var _arb:Class;
		
		private var _colInternal:Boolean = false;
		private var _resInternal:Boolean = false;
		
		private var _collections:Array = new Array();
		private var _simulators:Array = new Array();
		private var _arbiterList:ArbiterList = new ArbiterList();
		
		public function CollectionVsCollection(arbiter:Class=null, steps:Boolean=true, collides:Boolean=true, resolves:Boolean=true)
		{
			_arb = arbiter;
			
			_colInternal = collides;
			_resInternal = resolves;
		}
/**
 * Properties
 */	
		public function get collidesInternal():Boolean { return _colInternal; }
		public function set collidesInternal(value:Boolean):void { _colInternal = value; }
		
		public function get stepsInternal():Boolean { return false; }
		public function set stepsInternal(value:Boolean):void {  }
		
		public function get resolvesInternal():Boolean { return _resInternal; }
		public function set resolvesInternal(value:Boolean):void { _resInternal = value; }
		
/**
 * Methods
 */
		public function addPhysicsCollection( coll:IPhysicsCollection ):void
		{
			if(!this.containsPhysicsCollection( coll )) _collections.push(coll);
		}
		
		public function removePhysicsCollection( coll:IPhysicsCollection ):void
		{
			if(!this.containsPhysicsCollection(coll)) return;
			
			var index:int = _collections.indexOf(coll);
			_collections.splice(index,1);
		}
		
		public function containsPhysicsCollection( coll:IPhysicsCollection ):Boolean
		{
			Assertions.notNil( coll, "com.lordofduct.engines.physics::CollectionVsCollection - can not validate a null instance" );
			
			return Boolean( _collections.indexOf( coll ) >= 0 );
		}
		
		public function getPhysicsCollectionList():Array
		{
			return _collections.slice();
		}
	/**
	 * IPhysicsCollection methods Interface
	 */
		public function getPhysicalBodyList():Array
		{
			var arr:Array = new Array();
			
			for each( var coll:IPhysicsCollection in _collections )
			{
				arr = arr.concat( coll.getPhysicalBodyList() );
			}
			
			return arr;
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
		}
		
		public function collide():void
		{
			if(!_colInternal) return;
			
			var lists:Array = new Array();
			
			for each( var collection:IPhysicsCollection in _collections )
			{
				lists.push( collection.getPhysicalBodyList() );
			}
			
			var coll:Array, others:Array, temp:Array;
			var body1:IPhysicalAttrib, body2:IPhysicalAttrib;
			
			for each( coll in lists )
			{
				others = new Array();
				
				for each( temp in lists )
				{
					if (temp != coll) others = others.concat( temp );
				}
				
				while( coll.length )
				{
					body1 = coll.pop() as IPhysicalAttrib;
					
					for each( body2 in others )
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
		}
		
		public function collisionExistsFor( body:IPhysicalAttrib ):Boolean
		{
			var arr:Array = _arbiterList.arbiterExistsFor( body );
			
			for each( var arb:Arbiter in arr )
			{
				if(arb.collision) return true;
			}
			
			return false;
		}
		
		public function collisionsFor( body:IPhysicalAttrib ):Array
		{
			var arr:Array = _arbiterList.arbiterExistsFor( body );
			
			if(!arr) return null;
			
			for ( var i:int = 0; i < arr.length; i++ )
			{
				arr[i] = (arr[i] as Arbiter).collision;
			}
			
			return arr;
		}
	}
}