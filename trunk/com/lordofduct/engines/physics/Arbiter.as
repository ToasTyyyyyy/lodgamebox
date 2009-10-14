package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.collisionResolvers.ICollisionResolver;
	
	public class Arbiter
	{
		private var _body1:IPhysicalAttrib;
		private var _body2:IPhysicalAttrib;
		private var _latestCollisions:Array;
		
		
		public function Arbiter(b1:IPhysicalAttrib, b2:IPhysicalAttrib)
		{
			_body1 = b1;
			_body2 = b2;
		}
		
/**
 * Properties
 */
		public function get body1():IPhysicalAttrib { return _body1; }
		public function get body2():IPhysicalAttrib { return _body2; }
		
		public function get collisions():Array { return _latestCollisions.slice(); }
		public function set collisions(value:Array):void { _latestCollisions = value; }
/**
 * Methods
 */
		public function update( results:Array ):void
		{
			_latestCollisions = results.slice();
		}
		
		public function preStep( invDt:Number, dt:Number ):void
		{
			//OVERRIDE THIS BITCH
		}
		
		public function applyImpulse():void
		{
			//OVERRIDE THIS BITCH	
		}
		
		public function equals( obj:* ):Boolean
		{
			var arb:Arbiter = obj as Arbiter;
			
			if(!arb) return false;
			
			return ((_body1 == arb.body1 && _body2 == arb.body2) || (_body1 == arb.body2 && _body2 == arb.body1));
		}
	}
}