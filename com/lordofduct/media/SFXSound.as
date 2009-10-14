/**
 * SFXSound - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This most basic and unique ISFX object. Unlike most other ISFX objects 
 * this will ONLY allow its child to be of the Sound type. This class 
 * basically facilitates an easier way of handling and playing a Sound 
 * object.
 * 
 * Most of the events dispatched by the Sound object are no longer available 
 * through this class. With the exception of the Event.ID3 event. If you'd 
 * like to have access to these events, then create the Sound object yourself 
 * and pass it to this. Then you can listen for whatever you'd like.
 * 
 * WARNING - if you plan to save a reference to the Sound object outside of 
 * this class, do know that anything you do to it will not effect this class 
 * at all. If you generate a SoundChannel from it, stopping this object will 
 * not effect that SoundChannel at all.
 */
package com.lordofduct.media
{
	import com.lordofduct.events.SFXEvent;
	import com.lordofduct.util.LoDMath;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class SFXSound extends EventDispatcher implements ISFX
	{
		//info
		private var _id:String;
		private var _sound:Sound;
		private var _id3:ID3Info;
		
		//volume and playback objects
		private var _uri:*;
		private var _context:SoundLoaderContext;
		private var _transform:SoundTransform = new SoundTransform();
		private var _channel:SoundChannel;
		
		//local properties
		private var _isPlaying:Boolean = false;
		private var _isPaused:Boolean = false;
		private var _pausePosition:Number = 0;
		
		private var _totalLoops:int = 0;
		private var _loops:int = 0;
		private var _loopWatcher:Timer;
		
		public function SFXSound( id:String, snd:*=null, context:SoundLoaderContext=null )
		{
			super();
			
			_id = id;
			_uri = snd;
			_context = context;
			
			if(!(snd is Sound) && !(snd is String) && !(snd is Class)) throw new Error("gigo.media::SFXObject - object passed to SFXSound must be a Sound object or an url to a audio file");
			
			//If the snd was a Sound, then load it now and prepare the id3 data as it's already taking up memory
			if(_uri is Sound)
			{
				_sound = _uri;
				_id3 = _sound.id3;
			}
		}
		
/**
 * Public interface
 */
		public function get id3():ID3Info { return _id3; }
		public function get loops():int { return _loops; }
		public function get totalLoops():int { return _totalLoops; }
		
/**
 * Private interface
 */
		private function createChannel( pos:Number, lps:int, trans:SoundTransform ):void
		{
			if (_channel) destroyChannel();
			
			_channel = _sound.play( pos, lps, trans );
			if(!_channel)
			{
				this.stop();
				trace("gigo.media::SFXSound - ran out of sound channels");
				return;
			}
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
		
		private function id3InfoReady(e:Event):void
		{
			if(!_sound) return;
			
			_sound.removeEventListener( Event.ID3, id3InfoReady );
			_id3 = _sound.id3;
			
			this.dispatchEvent( new Event( Event.ID3 ) );
		}
		
		private function loadCompletionHandler(e:Event):void
		{
			_sound.removeEventListener( IOErrorEvent.IO_ERROR, loadCompletionHandler );
			_sound.removeEventListener( Event.COMPLETE, loadCompletionHandler );
			
			if(e is IOErrorEvent)
			{
				_sound.removeEventListener( Event.ID3, id3InfoReady );
				throw new Error("gigo.media::SFXSound - generated sound load failed to load. Please make sure the supplied URI matches.");
			}
		}
/**
 * ISFX interface
 */
		public function get id():String { return _id; }
		public function set id(value:String):void { _id = value; }
		public function get numChildren():int { return 1; }
		public function get length():Number { return _sound.length; }
		public function get position():Number
		{
			if (_isPaused) return _pausePosition;
			else if (_channel) return _channel.position;
			else return 0;
		}
		public function get isPlaying():Boolean { return _isPlaying; }
		public function get isPaused():Boolean { return _isPaused; }
	/**
	 * playback interface
	 */
		public function play( opts:Object=null ):void
		{
			if(!_sound) this.loadSound(_uri, _context);
			
			//start playing sound
			if (!opts) opts = new Object();
			if (_channel) _channel.stop();
			
			var startTime:Number = (opts.hasOwnProperty( "startTime" )) ? opts.startTime : 0;
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
			if (!_isPaused || _channel) return;
			
			var lps:int = _totalLoops - _loops;
			createChannel( _pausePosition, lps, _transform );
			createLoopWatcher();
			
			this.dispatchEvent( new SFXEvent( SFXEvent.RESUME ) );
		}
		
		public function pause():void
		{
			if (_isPaused || !_channel) return;
			
			_pausePosition = _channel.position;
			destroyChannel();
			destroyLoopWatcher();
			_isPaused = true;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PAUSE ) );
		}
		
		public function stop():void
		{
			destroyChannel();
			destroyLoopWatcher();
			_isPaused = false;
			_pausePosition = 0;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.STOP ) );
		}
		
		public function seek( pos:Number ):void
		{
			pos = LoDMath.clamp( pos, Sound(_sound).length );
			
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
			this.seek( per * Sound(_sound).length );
		}
		
	/**
	 * SoundTransform interface
	 */
		/**
		 * GET/SET the soundTransform of this object.
		 * WARNING - this is passed as a reference. If you edit the SoundTransform outside 
		 * of the SFXSound the SFXSound will not know. Always reset the value after editing.
		 */
	 	public function get soundTransform():SoundTransform { return _transform; }
		public function set soundTransform( value:SoundTransform ):void
		{
			_transform = value;
			if(_channel ) _channel.soundTransform = _transform;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.VOLUME_CHANGE ) );
		}
		
		public function get volume():Number { return _transform.volume; }
		public function set volume( value:Number ):void
		{
			_transform.volume = value;
			if(_channel ) _channel.soundTransform = _transform;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.VOLUME_CHANGE ) );
		}
		
		public function get panning():Number { return _transform.pan; }
		public function set panning( value:Number ):void
		{
			_transform.pan = value;
			if(_channel ) _channel.soundTransform = _transform;
		}
		
		public function mute():void
		{
			this.volume = 0;
		}
		
	/**
	 * Public load managing
	 */
		public function loadSound(snd:*, context:SoundLoaderContext=null):void
		{
			if(_sound) this.closeSound();
			
			_uri = snd;
			_context = context;
			
			if (snd is Sound)
			{
				//is snd is a Sound, then attach it
				_sound = snd;
				_id3 = _sound.id3;
			} else if (snd is String)
			{
				//if snd is a String, then attempt to load it as a uri
				_uri = snd as String;
				_sound = new Sound();
				_sound.addEventListener( IOErrorEvent.IO_ERROR, loadCompletionHandler, false, 0, true );
				_sound.addEventListener( Event.ID3, id3InfoReady, false, 0, true );
				_sound.addEventListener( Event.COMPLETE, loadCompletionHandler, false, 0, true );
				_sound.load( new URLRequest( snd ), context );
			} else if ( snd is Class)
			{
				//if snd is a class that extends Sound, attempt to instantiate it
				try
				{
					_sound = new snd();
				} catch (err:Error)
				{
					throw new Error("gigo.media::SFXObject - object passed to SFXSound must be a Sound object or a url to an audio file");
				}
			}else {
				throw new Error("gigo.media::SFXObject - object passed to SFXSound must be a Sound object or a url to an audio file");
			}
		}
		
		public function closeSound():void
		{
			this.stop();
			
			if(_sound)
			{
				_sound.removeEventListener( Event.ID3, id3InfoReady );
				_sound.removeEventListener( IOErrorEvent.IO_ERROR, loadCompletionHandler );
				_sound.removeEventListener( Event.COMPLETE, loadCompletionHandler );
				if(_uri is String)
				{
					//only close the Sound if it was loaded internally
					try
					{
						_sound.close();
					} catch(err:Error)
					{
						//do nothing, the sound couldn't be closed, no problems there
					}
				}
				
				_sound = null;
			}
			
			this.destroyChannel();
			this.destroyLoopWatcher();
		}
		
/**
 * IDipsose interface
 */
		protected var _disposed:Boolean = false;
		
		public function reengage(...args):void
		{
			var id:String = args[0], snd:* = args[1], context:SoundLoaderContext = args[2];
			_id = id;
			_uri = snd;
			_context = context;
			
			if(!(snd is Sound) && !(snd is String)) throw new Error("gigo.media::SFXObject - object passed to SFXSound must be a Sound object or a url to an audio file");
			
			_disposed = false;
		}
		
		public function dispose():void
		{
			if(_disposed) return;
			this.closeSound();
			
			_id = undefined;
			_uri = undefined;
			_context = undefined;
			
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