/**
 * KeyboardControls - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * <event> actionActivated - dispatched when a registered combination has been first activated
 * <event> actionRepeat - dispatched when a registered combination is repeated
 * <event> actionDeactivated - dispatched when a registered combination is released
 */
package com.lordofduct.ui
{
	import com.lordofduct.events.UInputEvent;
	import com.lordofduct.util.Assertions;
	
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class KeyboardController extends GameController
	{
		private var _dispatcher:EventDispatcher;
		
		private var _currentDowns:Array;
		private var _actionToCombo:Dictionary;
		private var _actionToActive:Dictionary;
		
		/**
		 * construct KeyboardControls
		 * 
		 * @param disp - the EventDispatcher for which to listen for KeyboardEvents. This object must be in focus for keyboard events to fire 
		 * on it. For global listening utilize the "stage" as the dispatcher. If something else is used and a key is pressed down or release 
		 * when out of focus it is completely ignored.
		 */
		public function KeyboardController( idx:String, disp:EventDispatcher=null )
		{
			super(idx);
			reset();
			registerDispatcher(disp);
		}
		
		/**
		 * register a new Dispatcher to listen for the key combinations
		 * 
		 * @param disp - the EventDispatcher for which to listen for KeyboardEvents. This object must be in focus for keyboard events to fire 
		 * on it. For global listening utilize the "stage" as the dispatcher. If something else is used and a key is pressed down or release 
		 * when out of focus it is completely ignored.
		 */
		public function registerDispatcher( disp:EventDispatcher=null ):void
		{
			if(!disp) disp = KeyboardManager.instance;
			
			if(_dispatcher)
			{
				_dispatcher.removeEventListener(UInputEvent.INPUT_PRESS, checkKeyDownCondition );
				_dispatcher.removeEventListener(UInputEvent.INPUT_HOLD, checkKeyHoldCondition );
				_dispatcher.removeEventListener(UInputEvent.INPUT_RELEASE, checkKeyUpCondition );
			}
			clearAllCurrents();
			
			_dispatcher = disp;
			
			_dispatcher.addEventListener(UInputEvent.INPUT_PRESS, checkKeyDownCondition, false, 0, true );
			_dispatcher.addEventListener(UInputEvent.INPUT_HOLD, checkKeyHoldCondition, false, 0, true );
			_dispatcher.addEventListener(UInputEvent.INPUT_RELEASE, checkKeyUpCondition, false, 0, true );
			KeyboardManager.instance.addEventListener(UInputEvent.INPUT_RESET, onInputReset, false, 0, true );
		}
		
		public function reset():void
		{	
			_currentDowns = new Array();
			_actionToCombo = new Dictionary();
			_actionToActive = new Dictionary();
		}
		
		/**
		 * Register some key combination to be monitored.
		 * 
		 * @param action - the id or name of the combination. This value will be passed with the event to let you know what combination was activated
		 * @param ...args - a list of Keyboard keys that match the combination. All params must be a uint.
		 * 
		 * ex: instance.registerAction( "someAction", 64, 53 );//"someAction" dispatches when both keys 64 and 53 are down
		 * 
		 * The registered combination is sorted numerically ascending and then stored.
		 */
		public function registerAction( action:String, ...args ):void
		{
			Assertions.notNilOrEmpty(args, "com.lordofduct.ui::KeyboardControls - some keyboard combination must be supplied as a series of params when registering actions" );
			
			var combo:Array = new Array();
			while( args.length ) combo.push( uint(args.shift()) );
			combo.sort(Array.NUMERIC);
			
			_actionToCombo[action] = combo;
			_actionToActive[action] = false;
		}
		
		/**
		 * Stop listening for some registered action
		 */
		public function removeAction( action:String ):void
		{
			delete _actionToCombo[action];
			delete _actionToActive[action];
		}
		
		/**
		 * Check if some named action is registered
		 */
		public function isRegistered( action:String ):Boolean
		{
			return Boolean( _actionToCombo[action] );
		}
		
		/**
		 * Is action currently activated?
		 */
		public function isActionActive( action:String ):Boolean
		{
			return _actionToActive[ action ];
		}
		
		/**
		 * Is action strictly activated. Returns true if and only if the supplied action's combination 
		 * is the ONLY keys currently pressed.
		 */
		public function isActionUnique( action:String ):Boolean
		{
			if (!this.isActionActive(action)) return false;
			
			var combo:String = _actionToCombo[ action ].join("");
			var downs:String = _currentDowns.join("");
			return combo == downs;
		}
		
		/**
		 * Is the supplied combination part of the currently pressed keys recorded by this instance
		 * 
		 * ex: var bool:Boolean = instance.isComboActive( 44, 52, 77 );
		 */
		public function isComboActive( ...keys ):Boolean
		{
			for each( var value:uint in keys )
			{
				if (_currentDowns.indexOf(value) < 0) return false;
			}
			
			return true;
		}
		
		/**
		 * Is the supplied combination strictly part of the currently pressed keys recorded by this instance
		 * Returns true if and only if the supplied combination is the ONLY keys currently pressed.
		 * 
		 * ex: var bool:Boolean = instance.isComboUnique( 44, 52, 77 );
		 */
		public function isComboUnique( ...keys ):Boolean
		{
			keys.sort(Array.NUMERIC);
			var combo:String = keys.join("");
			var downs:String = _currentDowns.join("");
			return combo == downs;
		}
		
		/**
		 * Returns an array of the key combination for a given action
		 * 
		 * the array is filled with numeric strings that are to be treated as uint
		 */
		public function getCombinationFor( action:String ):Array
		{
			return _actionToCombo[action].slice();
		}
		
		/**
		 * Returns an array of the currently pressed keys recorded by this instance
		 */
		public function getCurrentPressedKeys():Array
		{
			return _currentDowns.slice();
		}
		
/**
 * Private Interface
 */
		private function addCurrentDown(code:int):void
		{
			if(_currentDowns.indexOf(code) < 0)
			{
				_currentDowns.push(code);
				_currentDowns.sort(Array.NUMERIC);
			}
		}
		
		private function removeCurrentDown(code:int):void
		{
			var index:int = _currentDowns.indexOf(code);
			if(index >= 0) _currentDowns.splice(index,1);
		}
		
		private function assertActions(alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false):void
		{
			for ( var action:String in _actionToCombo )
			{
				var combo:Array = _actionToCombo[action];
				if (isComboActive.apply(this, combo))
				{
					var type:String = (_actionToActive[action]) ? UInputEvent.INPUT_HOLD : UInputEvent.INPUT_PRESS;
					_actionToActive[action] = true;
					this.dispatchEvent( new UInputEvent(type, false, false, action, alt, ctrl, shift ) );
				}
			}
		}
		
		private function desertActions(alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false):void
		{
			for ( var action:String in _actionToCombo )
			{
				var combo:Array = _actionToCombo[action];
				if (_actionToActive[action] && !isComboActive.apply(this, combo))
				{
					_actionToActive[action] = false;
					this.dispatchEvent( new UInputEvent( UInputEvent.INPUT_RELEASE, false, false, action, alt, ctrl, shift ) );
				}
			}
		}
		
	/**
	 * Cleaner functions
	 */
		private function clearAllCurrents(alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false):void
		{
			_currentDowns.splice();
			for (var action:String in _actionToActive)
			{
				_actionToActive[action] = false;
				this.dispatchEvent( new UInputEvent( UInputEvent.INPUT_RELEASE, false, false, action, alt, ctrl, shift ) );
			}
		}
/**
 * Event Listeners
 */
		private function checkKeyDownCondition(e:UInputEvent):void
		{
			addCurrentDown(e.code);
			
			assertActions(e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		private function checkKeyHoldCondition(e:UInputEvent):void
		{
			addCurrentDown(e.code);
			
			assertActions(e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		private function checkKeyUpCondition(e:UInputEvent):void
		{
			removeCurrentDown(e.code);
			
			desertActions(e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		private function onInputReset(e:UInputEvent):void
		{
			clearAllCurrents();
			this.dispatchEvent(e.clone());
		}
		
/**
 * IDisposable Interface
 */
		override public function reengage(...args):void
		{
			var idx:String = args[0], disp:EventDispatcher = args[1];
			
			super.reengage(idx);
			reset();
			registerDispatcher(disp);
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if(_dispatcher)
			{
				_dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, checkKeyDownCondition );
				_dispatcher.removeEventListener(KeyboardEvent.KEY_UP, checkKeyUpCondition );
				_dispatcher.removeEventListener(FocusEvent.FOCUS_OUT, onDispatcherFocusOut );
			}
			
			_dispatcher = null;
			_currentDowns = null;
			_actionToCombo = null;
			_actionToActive = null;
		}
	}
}