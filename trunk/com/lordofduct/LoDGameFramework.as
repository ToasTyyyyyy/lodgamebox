package com.lordofduct
{
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
		
		public function init(stg:Stage):void
		{
			_stage = stg;
		}
		
		public function get stage():Stage { return _stage; }
	}
}