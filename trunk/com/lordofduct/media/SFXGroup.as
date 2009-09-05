/**
 * SFXGroup - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This ISFX object facilitates grouping ISFX objects together 
 * to be controlled simultaneousily. By playing, pausing, seeking, 
 * etc. to this object you effect ALL ISFX objects that are children 
 * of this object.
 * 
 * If you'd like playlist style implementation, use the SFXPlaylist object.
 * 
 * This is merely intended to play multiple Sounds one on top of the other.
 * 
 * TODO - SFXGroup does not fire an SFXEvent.COMPLETE event. DO NOT use this inside 
 * the SFXPlaylist or other classes that depend on the SFXEvent.COMPLETE firing. I 
 * must implement some manner of capturing this event efficiently.
 * 
 * Really this object is a very basic and simple group not intended for much. It's 
 * mostly the footprint for SFXPlaylist, with plans of it being the footprint of 
 * other classes in the future. As is on its own it serves very little purpose.
 * 
 * It is made available merely to allow any creative mind to manhandle it into something 
 * more usable. There are some unique things about this class that give it potential... 
 * it just isn't well supported.
 */
package com.lordofduct.media
{
	import com.lordofduct.events.SFXEvent;
	
	import flash.events.EventDispatcher;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;

	public class SFXGroup extends EventDispatcher implements ISFX
	{
		private var _id:String;
		private var _transform:SoundTransform = new SoundTransform();
		
		protected var _sounds:Array = new Array();
		protected var _idToSFX:Dictionary = new Dictionary( true );
		
		public function SFXGroup( idx:String, ...args )
		{
			super();
			
			_id = idx;
			
			for each( var obj:ISFX in args )
			{
				this.addSFX( obj );
			}
		}
		
		public function addSFX( obj:ISFX ):void
		{
			if (!obj) throw new Error( "gigo.media::SFXGroup - ISFX to be added to a Group must be non-null" );
			
			if (_sounds.indexOf( obj ) < 0)
			{
				_sounds.push( obj );
				_sounds.sortOn( "length" );
			}
			
			obj.soundTransform = _transform;
			_idToSFX[obj.id] = obj;
		}
		
		public function removeSFX( obj:ISFX ):void
		{
			var index:int = _sounds.indexOf( obj );
			if (index < 0) return;
			
			_sounds.splice( index, 1 );
			delete _idToSFX[ obj.id ];
			if (obj.isPlaying) obj.stop();
		}
		
		public function contains( obj:ISFX ):Boolean
		{
			return !Boolean( _sounds.indexOf( obj ) < 0 );
		}
		
		public function containsById( idx:String ):Boolean
		{
			return !Boolean( _idToSFX[ idx ] );
		}
		
		public function getById( idx:String ):ISFX
		{
			return _idToSFX[ idx ];
		}
		
		public function removeById( idx:String ):void
		{
			if (this.containsById( idx )) this.removeSFX( this.getById( idx ) );
		}
/**
 * ISFX interface
 */
		public function get id():String { return _id; }
		public function set id(value:String):void { _id = value; }
		public function get numChildren():int { return _sounds.length; }
		/**
		 * length of the longest song in this group
		 */
		public function get length():Number
		{
			if (!_sounds.length) return 0;
			
			return _sounds[ _sounds.length - 1 ].length;
		}
		/**
		 * returns the position as is
		 */
		public function get position():Number
		{
			if (!_sounds.length) return 0;
			
			return _sounds[ _sounds.length - 1 ].position;
		}
		
		public function get isPlaying():Boolean
		{
			if (!_sounds.length) return false;
			
			return _sounds[ _sounds.length - 1 ].isPlaying;
		}
		
		public function get isPaused():Boolean
		{
			if (!_sounds.length) return false;
			
			return _sounds[ _sounds.length - 1 ].isPuased;
		}
		
	/**
	 * playback interface
	 */
		public function play( opts:Object=null ):void
		{
			if (!this.numChildren) return;
			
			var params:Object = new Object();
			params.startTime = (opts && opts.hasOwnProperty("startTime")) ? opts.startTime : 0;
			params.loops = 0;
			params.volume = (opts && opts.hasOwnProperty("volume")) ? opts.volume : this.soundTransform.volume;
			params.panning = (opts && opts.hasOwnProperty("panning")) ? opts.panning : this.soundTransform.pan;
			
			for each( var obj:ISFX in _sounds )
			{
				obj.play( opts );
			}
			
			this.soundTransform.volume = params.volume;
			this.soundTransform.pan = params.panning;
			this.soundTransform = this.soundTransform;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PLAY ) );
		}
		
		public function resume():void
		{
			for each( var obj:ISFX in _sounds )
			{
				obj.resume();
			}
			
			this.dispatchEvent( new SFXEvent( SFXEvent.RESUME ) );
		}
		
		public function pause():void
		{
			for each( var obj:ISFX in _sounds )
			{
				obj.pause();
			}
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PAUSE ) );
		}
		
		public function stop():void
		{
			for each( var obj:ISFX in _sounds )
			{
				obj.stop();
			}
			
			this.dispatchEvent( new SFXEvent( SFXEvent.STOP ) );
		}
		
		public function seek( pos:Number ):void
		{
			for each( var obj:ISFX in _sounds )
			{
				obj.seek( pos );
			}
		}
		
		public function seekToPercent( per:Number ):void
		{
			this.seek( this.length * per );
		}
		
	/**
	 * SoundTransform interface
	 */
		public function get soundTransform():SoundTransform { return _transform; }
		public function set soundTransform( value:SoundTransform ):void
		{
			_transform = value;
			
			for each( var obj:ISFX in _sounds )
			{
				obj.soundTransform = _transform;
			}
		}
		
		public function get volume():Number { return _transform.volume; }
		public function set volume( value:Number ):void
		{
			_transform.volume = value;
			
			for each( var obj:ISFX in _sounds )
			{
				obj.soundTransform = _transform;
			}
		}
		
		public function get panning():Number { return _transform.pan; }
		public function set panning( value:Number ):void
		{
			_transform.pan = value;
			
			for each( var obj:ISFX in _sounds )
			{
				obj.soundTransform = _transform;
			}
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
			var idx:String = args.shift();
			
			_id = idx;
			
			for each( var obj:ISFX in args )
			{
				this.addSFX( obj );
			}
		}
		
		public function dispose():void
		{
			if(_disposed) return;
			_id = undefined;
			_transform = undefined;
			_sounds = undefined;
			_idToSFX = undefined;
			_disposed = true;
		}
	}
}