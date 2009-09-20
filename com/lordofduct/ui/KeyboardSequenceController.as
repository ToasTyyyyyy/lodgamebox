package com.lordofduct.ui
{
	import com.lordofduct.events.UInputEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class KeyboardSequenceController extends KeyboardComboController
	{
		public static const CLEAN_TRAP:String = "sequenceCleanTrap";
		
		private var _sequences:Dictionary = new Dictionary();
		private var _curSequence:Array = new Array();
		
		private var _cdelay:int;
		private var _timer:Timer = new Timer(1000,1);
		
		public function KeyboardSequenceController(idx:String, disp:EventDispatcher=null, cleanDelay:int=1000)
		{
			super(idx, disp);
			
			this.cleanDelay = Math.max(0, cleanDelay);
			this.addEventListener(UInputEvent.INPUT_PRESS, inputSequenceListener, false, 0, true );
		}
		
		public function get cleanDelay():int { return _cdelay; }
		public function set cleanDelay(value:int):void
		{
			_cdelay = Math.max(0, cleanDelay);
			_timer.delay = _cdelay;
		}
/**
 * Public Interface
 */	
		override public function reset():void
		{
			super.reset();
			
			_sequences = new Dictionary();
		}
		
		public function registerSequence( id:String, ...args ):void
		{
			_sequences[id] = args;
			
			for ( var i:int = 0; i < args.length; i++ )
			{
				if(args[i] is uint)
				{
					var key:uint = args[i];
					var kid:String = "lodinter_" + key.toString();
					this.registerCombo(kid, key);
				}
			}
		}
		
		public function removeSequence( id:String ):void
		{
			var arr:Array = this.getSequenceFor(id);
			
			if(!arr) return;
			
			for (var i:int = 0; i < arr.length; i++)
			{
				if(arr[i] is uint)
				{
					var key:uint = arr[i];
					var kid:String = "lodinter_" + key.toString();
					this.removeCombo(kid);
				} else if( !(arr[i] is String) )
				{
					throw new Error( "ERROR" );
				}
			}
			
			delete _sequences[id];
		}
		
		override public function isRegistered(id:String):Boolean
		{
			if(_sequences[id]) return true;
			else return super.isRegistered(id);
		}
		
		public function getSequenceFor( id:String ):Array
		{
			for( seqId in _sequences )
			{
				combo = _sequences[seqId];
				
				
				
			}
			return (_sequences[id]) ? _sequences[id].slice() : null;
		}
		
/**
 * Private Interface
 */
		
	/**
	 * Cleaner functions
	 */
		override protected function clearAllCurrents(alt:Boolean=false, ctrl:Boolean=false, shift:Boolean=false):void
		{
			_curSequence.length = 0;
			
			super.clearAllCurrents(alt,ctrl,shift);
		}
		
/**
 * Event Listeners
 */
		private function inputSequenceListener(e:UInputEvent):void
		{
			var comboId:String = e.code;
			_curSequence.push(comboId);
			
			var bool:Boolean = false;
			
			var seqId:String, combo:Array, index:int, kid:String;
			
			for( seqId in _sequences )
			{
				combo = _sequences[seqId];
				index = _curSequence.length - 1;
				if(index >= combo.length) continue;
				kid = (combo[index] is uint) ? "lodinter_" + combo[index].toString() : combo[index];
				
				if(comboId == kid)
				{
					bool = true;
					
					if(index + 1 == combo.length)
					{
						this.dispatchEvent( new UInputEvent( UInputEvent.INPUT_PRESS, false, false, seqId, e.altKey, e.ctrlKey, e.shiftKey ) );
					}
				}
			}
			
			if(!bool)
			{
				_curSequence.length = 0;
			}
			
			_timer.reset();
			
			if(_cdelay)
			{
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, clearSequences, false, 0, true );
				_timer.start();
			}
		}
		
		private function clearSequences(e:TimerEvent):void
		{
			_curSequence.length = 0;
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, clearSequences);
			
			this.dispatchEvent( new UInputEvent( UInputEvent.INPUT_RESET, false, false, CLEAN_TRAP ) );
		}
/**
 * IDisposable Interface
 */
		override public function dispose():void
		{
			super.dispose();
			
			_sequences = null;
		}
	}
}