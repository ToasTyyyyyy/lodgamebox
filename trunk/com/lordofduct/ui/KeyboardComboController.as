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
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class KeyboardComboController extends GameController
	{
		private var _dispatcher:IEventDispatcher;
		
		private var _currentDowns:Array;
		private var _idToCombo:Dictionary;
		private var _idToActive:Dictionary;
		
		/**
		 * construct KeyboardControls
		 * 
		 * @param disp - the EventDispatcher for which to listen for KeyboardEvents. This object must be in focus for keyboard events to fire 
		 * on it. For global listening utilize the "stage" as the dispatcher. If something else is used and a key is pressed down or release 
		 * when out of focus it is completely ignored.
		 */
		public function KeyboardComboController( idx:String, disp:EventDispatcher=null )
		{
			super(idx);
			reset();
			registerDispatcher(disp);
		}
		
/**
 * Properties
 */
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
/**
 * Public Interface
 */
		/**
		 * register a new Dispatcher to listen for the key combinations
		 * 
		 * @param disp - the EventDispatcher for which to listen for KeyboardEvents. This object must be in focus for keyboard events to fire 
		 * on it. For global listening utilize the "stage" as the dispatcher. If something else is used and a key is pressed down or release 
		 * when out of focus it is completely ignored.
		 */
		public function registerDispatcher( disp:IEventDispatcher=null ):void
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
			_idToCombo = new Dictionary();
			_idToActive = new Dictionary();
		}
		
		/**
		 * Register some key combination to be monitored.
		 * 
		 * @param id - the id or name of the combination. This value will be passed with the event to let you know what combination was activated
		 * @param ...args - a list of Keyboard keys that match the combination. All params must be a uint.
		 * 
		 * ex: instance.registerCombo( "someCombo", 64, 53 );//"someCombo" dispatches when both keys 64 and 53 are down
		 * 
		 * The registered combination is sorted numerically ascending and then stored.
		 */
		public function registerCombo( id:String, ...args ):void
		{
			Assertions.notNilOrEmpty(args, "com.lordofduct.ui::KeyboardControls - some keyboard combination must be supplied as a series of params when registering combos" );
			
			var combo:Array = new Array();
			while( args.length ) combo.push( uint(args.shift()) );
			combo.sort(Array.NUMERIC);
			
			_idToCombo[id] = combo;
			_idToActive[id] = false;
		}
		
		/**
		 * Stop listening for some registered id
		 */
		public function removeCombo( id:String ):void
		{
			delete _idToCombo[id];
			delete _idToActive[id];
		}
		
		/**
		 * Check if some named combo is registered
		 */
		public function isRegistered( id:String ):Boolean
		{
			return Boolean( _idToCombo[id] );
		}
		
		/**
		 * Is id currently activated?
		 */
		public function isComboActive( id:String ):Boolean
		{
			return _idToActive[ id ];
		}
		
		/**
		 * Is combo strictly activated. Returns true if and only if the supplied combo's combination 
		 * is the ONLY keys currently pressed.
		 */
		public function isComboUnique( id:String ):Boolean
		{
			if (!this.isComboActive(id)) return false;
			
			var combo:String = _idToCombo[ id ].join("");
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
		 * Returns an array of the key combination for a given combo
		 * 
		 * the array is filled with numeric strings that are to be treated as uint
		 */
		public function getCombinationFor( id:String ):Array
		{
			return (_idToCombo[id]) ? _idToCombo[id].slice() : null;
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
		
		private function assertCombos(alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false):void
		{
			for ( var comboId:String in _idToCombo )
			{
				var combo:Array = _idToCombo[comboId];
				if (isComboActive.apply(this, combo))
				{
					var type:String = (_idToActive[comboId]) ? UInputEvent.INPUT_HOLD : UInputEvent.INPUT_PRESS;
					_idToActive[comboId] = true;
					this.dispatchEvent( new UInputEvent(type, false, false, comboId, alt, ctrl, shift ) );
				}
			}
		}
		
		private function desertCombos(alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false):void
		{
			for ( var comboId:String in _idToCombo )
			{
				var combo:Array = _idToCombo[comboId];
				if (_idToActive[comboId] && !isComboActive.apply(this, combo))
				{
					_idToActive[comboId] = false;
					this.dispatchEvent( new UInputEvent( UInputEvent.INPUT_RELEASE, false, false, comboId, alt, ctrl, shift ) );
				}
			}
		}
		
	/**
	 * Cleaner functions
	 */
		protected function clearAllCurrents(alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false):void
		{
			_currentDowns.splice();
			for (var comboId:String in _idToActive)
			{
				_idToActive[comboId] = false;
				this.dispatchEvent( new UInputEvent( UInputEvent.INPUT_RELEASE, false, false, comboId, alt, ctrl, shift ) );
			}
		}
/**
 * Event Listeners
 */
		protected function checkKeyDownCondition(e:UInputEvent):void
		{
			addCurrentDown(e.code);
			
			assertCombos(e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		protected function checkKeyHoldCondition(e:UInputEvent):void
		{
			addCurrentDown(e.code);
			
			assertCombos(e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		protected function checkKeyUpCondition(e:UInputEvent):void
		{
			removeCurrentDown(e.code);
			
			desertCombos(e.altKey, e.ctrlKey, e.shiftKey);
		}
		
		protected function onInputReset(e:UInputEvent):void
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
				_dispatcher.removeEventListener(UInputEvent.INPUT_PRESS, checkKeyDownCondition );
				_dispatcher.removeEventListener(UInputEvent.INPUT_HOLD, checkKeyHoldCondition );
				_dispatcher.removeEventListener(UInputEvent.INPUT_RELEASE, checkKeyUpCondition );
				_dispatcher.removeEventListener(FocusEvent.FOCUS_OUT, onInputReset );
			}
			
			_dispatcher = null;
			_currentDowns = null;
			_idToCombo = null;
			_idToActive = null;
		}
	}
}