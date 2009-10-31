package com.lordofduct.events
{
	import com.lordofduct.engines.physics.Collision;
	
	import flash.events.Event;

	public class PhysicsEvent extends Event
	{
		public static const COLLISION_UPDATED:String = "collisionUpdated";
		public static const COLLISION_OCCURRED:String = "collissionOccurred";
		public static const COLLISION_RESOLVED:String = "collissionResolved";
		public static const BODY_MOVED:String = "bodyMoved";
		
		protected var _result:Collision;
		
		public function get collision():Collision { return _result; }
		
		public function PhysicsEvent(type:String, result:Collision=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_result = result;
		}
		
		override public function clone():Event
		{
			return new PhysicsEvent( this.type, this.collision, this.bubbles, this.cancelable );
		}
	}
}