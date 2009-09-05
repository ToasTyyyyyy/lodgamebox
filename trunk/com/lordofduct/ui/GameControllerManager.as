package com.lordofduct.ui
{
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public class GameControllerManager extends Proxy
	{		
		private static var _inst:GameControllerManager;
		
		public static function get instance():GameControllerManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(GameControllerManager);
			
			return _inst;
		}
		
		public function GameControllerManager()
		{
			SingletonEnforcer.assertSingle(GameControllerManager);
		}
		
/**
 * STATIC PROPERTIES
 */
		public static const KEYBOARD_CONTROLLER:String = "KeyboardController";
		public static const MOUSE_CONTROLLER:String = "MouseController";
		
/**
 * Class Definition
 */
		private var _controls:Dictionary = new Dictionary();
			
		public function createGameController( type:String, idx:String, disp:EventDispatcher ):void
		{
			switch( type )
			{
				case KEYBOARD_CONTROLLER : this.registerGameController( new KeyboardController( idx, disp ) ); break;
				case MOUSE_CONTROLLER : this.registerGameController( new MouseController( idx, disp as InteractiveObject ) ); break;
				default this.registerGameController( new GameController( idx ) );
			}
		}
		
		public function registerGameController( controller:GameController ):void
		{
			_controls[controller.id] = controller;
		}
		
		public function removeGameController( idx:String ):void
		{
			delete _controls[idx];
		}
		
		public function isManager(idx:String):Boolean
		{
			return Boolean( _controls[idx] );
		}
		
		public function getGameController( idx:String ):GameController
		{
			return _controls[idx];
		}
		
/**
 * Proxy overrides
 */
		flash_proxy override function callProperty(methodName:*, ...args):*
		{
			trace("com.lordofduct.ui::GameControllerManager - Method {"+methodName+"} not found.");
			return null;
		}
		
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			var bool:Boolean = delete _controls[name];
			return bool;
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			return _controls[name];
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			return Boolean( _controls[name] );
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			trace("com.lordofduct.ui::GameControllerManager - Property {" + name + "} can not be set, create properties using the factory methods supplied.");
		}
	}
}