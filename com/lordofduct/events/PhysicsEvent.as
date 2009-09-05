package com.lordofduct.events
{
	import com.lordofduct.engines.physics.CollisionResult;
	
	import flash.events.Event;

	public class PhysicsEvent extends Event
	{
		public static const COLLISION:String = "collission";
		public static const COLLISION_RESOLVED:String = "collissionResolved";
		public static const BODY_MOVED:String = "bodyMoved";
		
		protected var _result:CollisionResult;
		
		public function get collisionResult():CollisionResult { return _result; }
		
		public function PhysicsEvent(type:String, result:CollisionResult=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_result = result;
		}
		
		override public function clone():Event
		{
			return new PhysicsEvent( this.type, this.collisionResult, this.bubbles, this.cancelable );
		}
	}
}