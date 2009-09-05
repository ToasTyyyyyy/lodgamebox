/**
 * SFXObject - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This is the simplest of all ISFX objects. It is merely a container. 
 * It CAN be used very similar to the SFXSound in that it accepts a Sound 
 * object as its child. But it also accepts all ISFX objects, and it also 
 * accepts any other object that happens to have a "soundTransform" property. 
 * 
 * WARNING - DO NOT pass an object that has a "soundTransform" property that 
 * is NOT of type SoundTransform. If you do, this object WILL throw errors.
 */
package com.lordofduct.media
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	import com.lordofduct.events.SFXEvent;
	import com.lordofduct.util.LoDMath;

	public class SFXObject extends EventDispatcher implements ISFX
	{
		public static const SOUND_TYPE:int = 0;
		public static const UNKNOWN_TYPE:int = 1;
		
		//info
		private var _id:String;
		private var _sound:*;
		private var _type:int = -1;
		
		//volume and playback objects
		private var _transform:SoundTransform = new SoundTransform();
		private var _channel:SoundChannel;
		
		//local properties
		private var _isPlaying:Boolean = false;
		private var _isPaused:Boolean = false;
		private var _pausePosition:Number = 0;
		
		private var _totalLoops:int = 0;
		private var _loops:int = 0;
		private var _loopWatcher:Timer;
		
		public function SFXObject( id:String, snd:*=null )
		{
			super();
			
			_id = id;
			
			if (snd is Sound || snd is ISFX)
			{
				_type = SOUND_TYPE;
				_sound = snd;
			} else if ( "soundTransform" in snd )
			{
				_type = UNKNOWN_TYPE;
				_sound = snd;
			} else {
				throw new Error("gigo.media::SFXObject - object passed to SFXObject must have a soundTransform property available");
			}
		}
		
/**
 * Public interface
 */
		public function get type():int { return _type; }
		public function get loops():int { return _loops; }
		public function get totalLoops():int { return _totalLoops; }
		
/**
 * Private interface
 */
		private function createChannel( pos:Number, lps:int, trans:SoundTransform ):void
		{
			if (_channel) destroyChannel();
			if (this.type == SFXObject.UNKNOWN_TYPE) return;
			
			_channel = _sound.play( pos, lps, trans );
			_channel.addEventListener( Event.SOUND_COMPLETE, onComplete, false, 0, true );
			_isPlaying = true;
			_isPaused = false;
			_pausePosition = 0;
			_totalLoops = lps;
		}
		
		private function destroyChannel():void
		{
			if (_channel)
			{
				_channel.stop();
				_channel.removeEventListener( Event.SOUND_COMPLETE, onComplete );
			}
			_channel = null;
			_isPlaying = false;
		}
		
		private function createLoopWatcher():void
		{
			if (_loopWatcher) destroyLoopWatcher();
			if (this.type == SFXObject.UNKNOWN_TYPE) return;
			if (_totalLoops <= 0) return;
			if (!_channel) return;
			
			var dur:Number = LoDMath.clamp( this.length - this.position, this.length );
			_loopWatcher = new Timer( dur, 1 );
			_loopWatcher.addEventListener( TimerEvent.TIMER_COMPLETE, onLoop, false, 0, true );
		}
		
		private function destroyLoopWatcher():void
		{
			if (_loopWatcher)
			{
				_loopWatcher.stop();
				_loopWatcher.removeEventListener( TimerEvent.TIMER_COMPLETE, onLoop );
				_loopWatcher = null;
			}
		}
/**
 * Event Listeners
 */
		private function onComplete(e:Event):void
		{
			this.dispatchEvent( new SFXEvent( SFXEvent.COMPLETE ) );
		}
		
		private function onLoop(e:TimerEvent):void
		{
			_loops++;
			destroyLoopWatcher();
			if (_loops < _totalLoops) createLoopWatcher();
			
			this.dispatchEvent( new SFXEvent( SFXEvent.LOOP ) );
		}
/**
 * ISFX interface
 */
		public function get id():String { return _id; }
		public function set id(value:String):void { _id = value; }
		public function get numChildren():int { return 1; }
		public function get length():Number
		{
			if (this.type == SFXObject.UNKNOWN_TYPE) return -1;
			else return _sound.length;
		}
		public function get position():Number
		{
			if (this.type == SFXObject.UNKNOWN_TYPE) return -1;
			else if (_isPaused) return _pausePosition;
			else if (_channel) return _channel.position;
			else return 0;
		}
		public function get isPlaying():Boolean { return _isPlaying; }
		public function get isPaused():Boolean { return _isPaused; }
		
	/**
	 * playback interface
	 * 
	 * UNKNOWN_TYPE can not be accessed through these
	 */
		public function play( opts:Object=null ):void
		{
			if(this.type == SFXObject.UNKNOWN_TYPE )
			{
				trace("WARNING: An audible object cannot 'play' a UKNOWN_TYPE object it's managing.");
				return;
			}
			
			//start playing sound
			if (!opts) opts = new Object();
			if (_channel) _channel.stop();
			
			
			var startTime:Number = (opts.hasOwnProperty( "startTime" )) ? opts.starTime : 0;
			var lps:int = (opts.hasOwnProperty( "loops" )) ? opts.loops : 0;
			_transform.pan = (opts.hasOwnProperty( "panning" )) ? opts.panning : _transform.pan;
			_transform.volume = ( opts.hasOwnProperty( "volume" ) ) ? opts.volume : _transform.volume;
			
			createChannel( startTime, lps, _transform );
			_loops = 0;
			createLoopWatcher();
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PLAY ) );
		}
		
		public function resume():void
		{
			if (this.type == SFXObject.UNKNOWN_TYPE) return;
			if (!_isPaused || _channel) return;
			
			var lps:int = _totalLoops - _loops;
			createChannel( _pausePosition, lps, _transform );
			createLoopWatcher();
			
			this.dispatchEvent( new SFXEvent( SFXEvent.RESUME ) );
		}
		
		public function pause():void
		{
			if (this.type == SFXObject.UNKNOWN_TYPE) return;
			if (_isPaused || !_channel) return;
			
			_pausePosition = _channel.position;
			destroyChannel();
			destroyLoopWatcher();
			_isPaused = true;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PAUSE ) );
		}
		
		public function stop():void
		{
			if (this.type == SFXObject.UNKNOWN_TYPE) return;
			
			destroyChannel();
			destroyLoopWatcher();
			_isPaused = false;
			_pausePosition = 0;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.STOP ) );
		}
		
		public function seek( pos:Number ):void
		{
			if (this.type == SFXObject.UNKNOWN_TYPE) return;
			
			pos = LoDMath.clamp( pos, _sound.length );
			
			if (_channel)
			{
				destroyChannel();
				var lps:int = _totalLoops - _loops;
				createChannel( pos, lps, _transform );
				createLoopWatcher();
			} else if (_isPaused)
			{
				_pausePosition = pos;
			}
		}
		
		public function seekToPercent( per:Number ):void
		{
			if (this.type == SFXObject.UNKNOWN_TYPE) return;
			
			this.seek( per * _sound.length );
		}
		
	/**
	 * SoundTransform interface
	 */
		/**
		 * GET/SET the soundTransform of this object.
		 * WARNING - this is passed as a reference. If you edit the SoundTransform outside 
		 * of the SFXObject the SFXObject will not know. Always reset the value after editing.
		 */
	 	public function get soundTransform():SoundTransform { return _transform; }
		public function set soundTransform( value:SoundTransform ):void
		{
			_transform = value;
			if( this.type == SFXObject.SOUND_TYPE && _channel ) _channel.soundTransform = _transform;
			else if( this.type == SFXObject.UNKNOWN_TYPE ) _sound.soundTransform = _transform;
		}
		
		public function get volume():Number { return _transform.volume; }
		public function set volume( value:Number ):void
		{
			_transform.volume = value;
			if( this.type == SFXObject.SOUND_TYPE && _channel ) _channel.soundTransform = _transform;
			else if( this.type == SFXObject.UNKNOWN_TYPE ) _sound.soundTransform = _transform;
		}
		
		public function get panning():Number { return _transform.pan; }
		public function set panning( value:Number ):void
		{
			_transform.pan = value;
			if( this.type == SFXObject.SOUND_TYPE && _channel ) _channel.soundTransform = _transform;
			else if( this.type == SFXObject.UNKNOWN_TYPE ) _sound.soundTransform = _transform;
		}
		
		public function mute():void
		{
			this.volume = 0;
		}
		
/**
 * IDipsose interface
 */
		protected var _disposed:Boolean = false;
		
		public function reengage(...args):void
		{
			var id:String = args[0], snd:* = args[1];
			
			_id = id;
			
			if (snd is Sound || snd is ISFX)
			{
				_type = SOUND_TYPE;
				_sound = snd;
			} else if ( "soundTransform" in snd )
			{
				_type = UNKNOWN_TYPE;
				_sound = snd;
			} else {
				throw new Error("gigo.media::SFXObject - object passed to SFXObject must have a soundTransform property available");
			}
		}
		
		public function dispose():void
		{
			if(_disposed) return;
			this.destroyChannel();
			this.destroyLoopWatcher();
			
			_id = undefined;
			_type = undefined;
			_sound = undefined;
			_transform = undefined;
			_channel = undefined;
			_isPlaying = undefined;
			_isPaused = undefined;
			_pausePosition = undefined;
			_totalLoops = undefined;
			_loops = undefined;
			_loopWatcher = undefined;
			_disposed = true;
		}
	}
}