/**
 * LoDPhysicsEngine - written by Dylan Engelman a.k.a LordOfDuct
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
package com.lordofduct.engines.physics
{
	import com.lordofduct.events.PhysicsEvent;
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.DeltaTimer;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	public class LoDPhysicsEngine extends EventDispatcher
	{
		private static var _inst:LoDPhysicsEngine;
		
		public static function get instance():LoDPhysicsEngine
		{
			if (!_inst) _inst = SingletonEnforcer.gi(LoDPhysicsEngine);
			
			return _inst;
		}
		
		public function LoDPhysicsEngine()
		{
			SingletonEnforcer.assertSingle(LoDPhysicsEngine);
		}
/**
 * Class Definition
 */	
		public function init( uSwitch:DeltaTimer=null ):void
		{
			if(!uSwitch) uSwitch = new DeltaTimer();
			this.changeUpdateSwitch(uSwitch);
		}
		
	/**
	 * Properties
	 */
		private var _switch:DeltaTimer;
		private var _groups:Array = new Array();
		private var _detail:uint = 1;
		
		/**
		 * A reference to the DeltaTimer used to update the Physics. 
		 * 
		 * The engine updates every cycle of the DeltaTimer, so if you want to update 
		 * the engine just update the updateSwitch. There are 3 basic DeltaTimers available:
		 * DeltaTimer - you manually update this switch
		 * DeltaFrameTimer - this timer updates every frame
		 * DeltaPulseTimer - this timer updates by a TimerDelay <-- LoD prefers this choice!
		 * 
		 * More frequent updates from the switch mean more power processing required.
		 */
		public function get updateSwitch():DeltaTimer { return _switch; }
		
		/**
		 * How detailed is each update pulse. The engine will integrate across delta time 
		 * this many times. So if value is 4, the engine updates 4 times per switch update.
		 * Larger numbers increase accuracy, but also increase processing power required.
		 * 
		 * Minimum value is 1
		 */
		public function get detail():uint { return _detail; }
		public function set detail(value:uint):void { _detail = Math.max(1,value); }
		
	/**
	 * Public Methods
	 */
		/**
		 * Change out the DeltaTimer being used as the updateSwitch.
		 * 
		 * You may want to grab a reference to the old one before swapping. This way 
		 * you can stop it or do what ever you please with it.
		 */
		public function changeUpdateSwitch( uSwitch:DeltaTimer ):void
		{
			Assertions.notNil(uSwitch, "com.lordofduct.engines.phsyics::LoDPhysicsEngine - updateSwitch param must be non-null");
			
			if(_switch) _switch.removeEventListener(TimerEvent.TIMER, onSwitchUpdate );
			
			_switch = (uSwitch) ? uSwitch : new DeltaTimer();
			_switch.addEventListener(TimerEvent.TIMER, onSwitchUpdate, false, 0, true );
		}
		
		
		/**
		 * Add a PhysicalBody to be managed
		 */
		public function addPhysicsCollection( group:IPhysicsCollection ):void
		{
			this.removePhysicsCollection( group );
			_groups.push(group);
		}
		
		/**
		 * Remove a PhysicalBody
		 */
		public function removePhysicsCollection( group:IPhysicsCollection ):void
		{
			var index:int = _groups.indexOf(group);
			if(index >= 0) _groups.splice(index,1);
		}
		
		public function clearAllPhysicsCollections():void
		{
			_groups.length = 0;
		}
		
		
		
		public function constructArbiter( b1:IPhysicalAttrib, b2:IPhysicalAttrib, arbiterType:Class ):Arbiter
		{
			try
			{
				var arb:Arbiter = new arbiterType(b1,b2) as Arbiter;
				if(!arb) Assertions.throwError("com.lordofduct.com.engines::LoDPhysicsEngine - Arbiter type does not extend Arbiter.");
				return arb;
			} catch(err:Error)
			{
				Assertions.throwError("com.lordofduct.com.engines::LoDPhysicsEngine - Arbiter type does not extend Arbiter.");
			}
			
			return null;
		}
		
		public function constructCollision( b1:IPhysicalAttrib, b2:IPhysicalAttrib, collisionType:Class ):Collision
		{
			try
			{
				var col:Collision = new collisionType( b1, b2 ) as Collision;
				if(!col) Assertions.throwError("com.lordofduct.com.engines::LoDPhysicsEngine - Collision type does not extend Collision.", Error);
				return col;
			} catch(err:Error)
			{
				Assertions.throwError("com.lordofduct.com.engines::LoDPhysicsEngine - Collision type does not extend Collision.", Error);
			}
			
			return null;
		}
		
		public function constructCollisionChosen( b1:IPhysicalAttrib, b2:IPhysicalAttrib ):Collision
		{
			try
			{
				var col1:Collision = new b1.collisionMesh.collisionDetector(b1,b2) as Collision;
				var col2:Collision = new b2.collisionMesh.collisionDetector(b1,b2) as Collision;
				
				if(!col1 || !col2) Assertions.throwError("com.lordofduct.com.engines::LoDPhysicsEngine - Collision type does not extend Collision.", Error);
				
				return (col1.weight > col2.weight) ? col1 : col2;
			} catch(err:Error)
			{
				Assertions.throwError("com.lordofduct.com.engines::LoDPhysicsEngine - Collision type does not extend Collision.", Error);
			}
			
			return null;
		}
		
	/**
	 * Update Physics
	 */
		private function onSwitchUpdate(e:TimerEvent):void
		{
			var dt:Number = this.updateSwitch.dt / this.detail;
			
			for (var i:int = 0; i < this.detail; i++)
			{
				updatePositions(dt);
			}
		}
		
		private function updatePositions(dt:Number):void
		{
			for each( var group:IPhysicsCollection in _groups )
			{
				group.step(dt);
				group.collide();
			}
		}
		
		public function poolCollisionResult( result:CollisionResult ):void
		{
			if(result)
			{
				this.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION, result ) );
				if(result.body1) result.body1.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION, result ) );
				if(result.body2) result.body2.dispatchEvent( new PhysicsEvent( PhysicsEvent.COLLISION, result ) );
			}
		}
	}
}