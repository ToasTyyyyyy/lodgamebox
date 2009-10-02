package com.lordofduct
{
	import com.lordofduct.util.DeltaTimer;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;

	dynamic public class LoDGameFramework extends EventDispatcher
	{
		private static var _inst:LoDGameFramework;
		
		public static function get instance():LoDGameFramework
		{
			if (!_inst) _inst = SingletonEnforcer.gi(LoDGameFramework);
			
			return _inst;
		}
		
		public static function get instantiated():Boolean
		{
			return _inst != null && instance.stage;
		}
		
		public function LoDGameFramework()
		{
			SingletonEnforcer.assertSingle(LoDGameFramework);
		}
		
/**
 * Class Definition
 */
		private var _stage:Stage;
		private var _gameTimer:DeltaTimer;
		
		public function init(stg:Stage, dTimer:DeltaTimer=null ):void
		{
			_stage = stg;
			_gameTimer = dTimer;
		}
		
		public function get stage():Stage { return _stage; }
		
		public function get gameTimer():DeltaTimer { return _gameTimer; }
		
		
		
		public function attachGlobal( idx:String, obj:* ):void
		{
			this[idx] = obj;
		}
		
		public function removeGlobal( idx:String ):void
		{
			this[idx] = undefined;
		}
	}
}