/**
 * SFXSound - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This object facilitates layer multiple copies of the same sound effect. By 
 * accessing play the sound effect is played on top of any previous plays of the 
 * sound effect. So you can repeatedly play it over and over creating multiple 
 * effects on top of each other. This should be used for Sound effects in games 
 * and the sort... for instance the sound of a grenade exploding, there can be multiple 
 * grenadeds blowing up, so this allows a distinct channel to be created for each grenade. 
 * Still bar in mind the maximum number of channels available. So 30 grenades exploding at once will 
 * only leave 2 channels open for other things.
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
 * 
 * 
 * 
 * DIFFERENCES FROM OTHER ISFX objects:
 * 
 * This object allows you to loop, but it doesn't dispatch loop events. It would be difficult 
 * and cumbersome to figure out WHICH channel was making doing the loop. Complete events still fire for each 
 * plug at "play".
 * 
 * TODO - implement pause, resume and seek. At this time they act as: stop, play, nothing for the time being. 
 * 
 * Probably won't even implement these actions as well merely because this object is really meant for quick 
 * sound effects that shouldn't need to be paused, resumed, or seeked. You can of course start the SFX at any given 
 * point still.
 */
package com.lordofduct.media
{
	import com.lordofduct.events.SFXEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	public class SFXNoise extends EventDispatcher implements ISFX
	{
		//info
		private var _id:String;
		private var _sound:Sound;
		private var _id3:ID3Info;
		
		//volume and playback objects
		private var _uri:*;
		private var _context:SoundLoaderContext;
		private var _transform:SoundTransform = new SoundTransform();
		private var _channels:Array = new Array();
		
		//local properties
		private var _isPlaying:Boolean = false;
		
		public function SFXNoise( id:String, snd:*=null, context:SoundLoaderContext=null )
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
		public function get loops():int { return -1; }
		public function get totalLoops():int { return -1; }
		
/**
 * Private interface
 */
		private function createChannel( pos:Number, lps:int, trans:SoundTransform ):void
		{
			var chan:SoundChannel = _sound.play( pos, lps, trans );
			if(!chan)
			{
				trace("gigo.media::SFXSound - ran out of sound channels");
				return;
			}
			chan.addEventListener( Event.SOUND_COMPLETE, onComplete, false, 0, true );
			_isPlaying = true;
		}
		
		private function destroyChannels():void
		{
			for each(var chan:SoundChannel in _channels)
			{
				chan.stop();
				chan.removeEventListener( Event.SOUND_COMPLETE, onComplete );
			}
			_channels.length = 0;
			_isPlaying = false;
		}
/**
 * Event Listeners
 */
		private function onComplete(e:Event):void
		{
			var chan:SoundChannel = e.currentTarget as SoundChannel;
			
			if(!chan) return;
			
			var index:int = _channels.indexOf( chan );
			
			if(index < 0) return;
			
			_channels.splice(index,1);
			chan.stop();
			chan.removeEventListener( Event.SOUND_COMPLETE, onComplete );
			
			if(_channels.length == 0)
			{
				_isPlaying = false;
			}
			
			this.dispatchEvent( new SFXEvent( SFXEvent.COMPLETE ) );
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
			if (_channels[0]) return _channels[0].position;
			else return 0;
		}
		public function get isPlaying():Boolean { return _isPlaying; }
		public function get isPaused():Boolean { return false; }
	/**
	 * playback interface
	 */
		public function play( opts:Object=null ):void
		{
			if(!_sound) this.loadSound(_uri, _context);
			
			//start playing sound
			if (!opts) opts = new Object();
			
			var startTime:Number = (opts.hasOwnProperty( "startTime" )) ? opts.startTime : 0;
			var lps:int = (opts.hasOwnProperty( "loops" )) ? opts.loops : 0;
			_transform.pan = (opts.hasOwnProperty( "panning" )) ? opts.panning : _transform.pan;
			_transform.volume = ( opts.hasOwnProperty( "volume" ) ) ? opts.volume : _transform.volume;
			
			createChannel( startTime, lps, _transform );
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PLAY ) );
		}
		
		public function resume():void
		{
			//TODO
			this.play();
		}
		
		public function pause():void
		{
			//TODO
			this.stop();
		}
		
		public function stop():void
		{
			destroyChannels();
			
			this.dispatchEvent( new SFXEvent( SFXEvent.STOP ) );
		}
		
		public function seek( pos:Number ):void
		{
			//TODO
		}
		
		public function seekToPercent( per:Number ):void
		{
			//TODO
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
			
			for each( var chan:SoundChannel in _channels )
			{
				chan.soundTransform = _transform;
			}
		}
		
		public function get volume():Number { return _transform.volume; }
		public function set volume( value:Number ):void
		{
			_transform.volume = value;
			
			for each( var chan:SoundChannel in _channels )
			{
				chan.soundTransform = _transform;
			}
		}
		
		public function get panning():Number { return _transform.pan; }
		public function set panning( value:Number ):void
		{
			_transform.pan = value;
			
			for each( var chan:SoundChannel in _channels )
			{
				chan.soundTransform = _transform;
			}
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
			
			this.destroyChannels();
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
			_transform = new SoundTransform();
			_channels = new Array();
			
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
			_channels = undefined;
			_isPlaying = undefined;
			_disposed = true;
		}
	}
}