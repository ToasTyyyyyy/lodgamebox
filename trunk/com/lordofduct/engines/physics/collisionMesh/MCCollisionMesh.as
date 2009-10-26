package com.lordofduct.engines.physics.collisionMesh
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class MCCollisionMesh extends DOCollisionMesh
	{
		private var _valUp:Boolean = false;
		
		public function MCCollisionMesh(disObj:DisplayObject, alg:Class=null, validOnUpdate:Boolean=false)
		{
			super(disObj, alg);
			
			this.validateOnUpdate = validOnUpdate;
		}
		
		public function get validateOnUpdate():Boolean { return _valUp; }
		public function set validateOnUpdate(value:Boolean):void
		{
			_valUp = value;
			
			if(_valUp)
			{
				this.relatedDisplayObject.addEventListener(Event.ENTER_FRAME, validateOnUpdateListener, false, 0, true );
			} else {
				this.relatedDisplayObject.removeEventListener( Event.ENTER_FRAME, validateOnUpdateListener );
			}
		}
		
		private function validateOnUpdateListener(e:Event):void
		{
			this.invalidate();
		}
	}
}