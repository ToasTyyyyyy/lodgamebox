/**
 * SFXPlaylist - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This ISFX object extends the SFXGroup one step further. The group of 
 * objects are played one after the other instead. And also facilitates 
 * sorting the list of ISFX objects.
 * 
 */
package com.lordofduct.media
{
	import com.lordofduct.events.SFXEvent;
	import com.lordofduct.util.LoDMath;

	public class SFXPlaylist extends SFXGroup
	{
		private var _currentTrack:ISFX;
		private var _currentTrackPos:int = 0;
		
		private var _continuous:Boolean = false;
		private var _repeat:Boolean = false;
		private var _subloops:int = 0;
		
		public function SFXPlaylist( idx:String, ...args )
		{
			super( idx );
			
			for each( var obj:ISFX in args )
			{
				this.addSFX( obj );
			}
		}
		
/**
 * Public interface
 */
		/**
		 * Does each song stream one after the other
		 */
		public function get continuous():Boolean { return _continuous; }
		public function set continuous( value:Boolean ):void { _continuous = value; }
		/**
		 * Does the playlist repeat? If continuous is true then the entire 
		 * playlist loops around. If continuous is false, the current track keeps 
		 * looping.
		 */
		public function get repeat():Boolean { return _repeat; }
		public function set repeat( value:Boolean ):void { _repeat = value; }
		/**
		 * subloops refers to how many times the currentTrack object should loop, 
		 * if it can loop, before moving on to the next track.
		 */
		public function get subloops():int { return _subloops; }
		public function set subloops( value:int ):void { _subloops = value; }
		public function get currentTrackPosition():int { return _currentTrackPos; } //0 point based... equal to index in array
		
		override public function addSFX( obj:ISFX ):void
		{
			if (!obj) throw new Error( "gigo.media::SFXGroup - ISFX to be added to a Group must be non-null" );
			
			if (_sounds.indexOf( obj ) < 0)
			{
				_sounds.push( obj );
			}
			
			obj.soundTransform = this.soundTransform;
			_idToSFX[obj.id] = obj;
		}
		
		override public function removeSFX(obj:ISFX):void
		{
			super.removeSFX( obj );
			
			_currentTrackPos = LoDMath.clamp( _currentTrackPos, this.numChildren - 1 );
			if (obj == _currentTrack) this.stop();
		}
		
		public function trackForward():void
		{
			var value:int = _currentTrackPos + 1;
			if( _continuous ) value = LoDMath.wrap( value, this.numChildren );
			else value = LoDMath.clamp( value, this.numChildren );
			this.gotoTrack( value );
		}
		
		public function trackBackward():void
		{
			var value:int = _currentTrackPos - 1;
			if( _continuous ) value = LoDMath.wrap( value, this.numChildren );
			else value = LoDMath.clamp( value, this.numChildren );
			this.gotoTrack( value );
		}
		
		public function gotoTrack( index:int ):void
		{
			index = LoDMath.clamp( index, this.numChildren - 1 );
			_currentTrackPos = index;
			if (this.isPlaying) this.play();
		}
		
		public function gotoTrackById( idx:String ):void
		{
			if (!this.containsById(idx)) return;
			
			this.gotoTrack( this._sounds.indexOf( this.getById(idx) ) );
		}
		
		public function gotoTrackByReference( obj:ISFX ):void
		{
			if (!this.contains( obj )) return;
			
			this.gotoTrack( this._sounds.indexOf( obj ) );
		}
		
		/**
		 * grab a reference to the current track playing if any.
		 * DO NOT use this as an interface to play, pause, etc the track.
		 * This is mostly useful for grabbing at type specifc props.
		 */
		public function get currentTrack():ISFX
		{
			return _currentTrack;
		}
		
	/**
	 * Sorting methods
	 * 
	 * WARNING - these methods are intended to assist sorting the playlist while 
	 * it is in play. Avoid using these methods unless otherwise necessary. It 
	 * is advised to just destroy this playlist and replace it with a new one instead.
	 */
		/**
		 * sort the ISFX objects in this playlist by some property made public by ISFX. 
		 * This acts exactly like Array.sortOn(...);
		 */
	 	public function sortOn( fieldName:Object, options:Object=null ):void
	 	{
	 		_sounds.sortOn( fieldName, options );
	 		if (_currentTrack)
	 		{
	 			_currentTrackPos = _sounds.indexOf( _currentTrack );
	 		}
	 	}
	 	
	 	/**
	 	 * retrieve an array describing the list of tracks in this playlist in the order 
	 	 * they are playing at this moment. Use this array to manually sort the list and 
	 	 * pass it back to the playlist through "reorderPlaylist".
	 	 * 
	 	 * This can also be used to grab references to all the tracks. Do not play, pause, etc. 
	 	 * these tracks as it side steps the control features of this object causing errors. It 
	 	 * can be used to grab sub-properties like id3 info.
	 	 */
	 	public function getReorderList():Array
	 	{
	 		return _sounds.concat();
	 	}
	 	
	 	/**
	 	 * After retrieving the array of current songs from "getReorderList", and manually 
	 	 * sorting the array on your own, you can pass it back through this method to 
	 	 * attempt to rebuild the PlayList.
	 	 * 
	 	 * WARNING - do NOT add or remove items from the list without also performing 
	 	 * "removeSFX" on the playlist itself. The array is intended merely for reordering.
	 	 * 
	 	 * Failure to follow said rule will result in errors and memory leaks.
	 	 * 
	 	 * The mere purpose of this method is so that you can actively sort a playlist WHILE 
	 	 * the playlist is playing. Otherwise it is best to just destroy this playlist and 
	 	 * create a brand new one.
	 	 */
	 	public function applyReorderlist( arr:Array ):void
	 	{
	 		if(!arr || arr.length != _sounds.length)
	 		{
	 			throw new Error("gigo.media::SFXPlaylist - the supplied array used to reorder does not include all the same tracks." );
	 			return;
	 		}
	 		
	 		for each( var sfx:ISFX in arr )
	 		{
	 			if (!this.contains(sfx)) throw new Error("gigo.media::SFXPlaylist - the supplied array used to reorder does not include all the same tracks." );
	 			return;
	 		}
	 		
	 		_sounds = arr;
	 		if (_currentTrack)
	 		{
	 			_currentTrackPos = _sounds.indexOf( _currentTrack );
	 		}
	 	}
/**
 * Private interface
 */
		private function createCurrentTrack():void
		{
			if (!this.numChildren) return;
			
			destroyCurrentTrack();
			_currentTrack = _sounds[ _currentTrackPos ];
			_currentTrack.addEventListener( SFXEvent.COMPLETE, continueToNextTrack, false, 0, true );
		}
		
		private function destroyCurrentTrack():void
		{
			_currentTrack = null;
			
			for each( var sfx:ISFX in this._sounds )
			{
				sfx.removeEventListener( SFXEvent.COMPLETE, continueToNextTrack );
				sfx.stop();
			}
		}
/**
 * Event Listeners
 */
		private function continueToNextTrack(e:SFXEvent):void
		{	
			if(_continuous && _repeat)
			{
				//if the playlist loops around forever
				_currentTrackPos++;
				
				if(_currentTrackPos >= this.numChildren)
				{
					_currentTrackPos = 0;
					this.dispatchEvent( new SFXEvent( SFXEvent.LOOP ) );
				}
				
				this.play();
				this.dispatchEvent( new SFXEvent( SFXEvent.TRACK_CHANGE ) );
			} else if (_continuous && !_repeat) {
				//if the playlist plays until it reaches the last track
				_currentTrackPos++;
				
				if( _currentTrackPos >= this.numChildren)
				{
					_currentTrackPos = 0;
					destroyCurrentTrack();
					this.dispatchEvent( new SFXEvent( SFXEvent.COMPLETE ) );
				} else {
					this.play();
					this.dispatchEvent( new SFXEvent( SFXEvent.TRACK_CHANGE ) );
				}
			} else if (!_continuous && _repeat) {
				//if the playlist repeats the track it is on
				this.play();
				this.dispatchEvent( new SFXEvent( SFXEvent.TRACK_CHANGE ) );
			} else {
				//if the playlist stops after the song is done playing
				_currentTrackPos = 0;
				destroyCurrentTrack();
				this.dispatchEvent( new SFXEvent( SFXEvent.COMPLETE ) );
			}
		}
/**
 * ISFX interface
 */
		/**
		 * returns the length of the currently playing ISFX
		 */
		override public function get length():Number
		{
			return ( _currentTrack ) ? _currentTrack.length : 0;
		}
		/**
		 * returns the position of the currently playing ISFX
		 */
		override public function get position():Number
		{
			return ( _currentTrack ) ? _currentTrack.position : 0;
		}
		
		override public function get isPlaying():Boolean
		{
			if (!_currentTrack) return false;
			
			return _currentTrack.isPlaying;
		}
		
		override public function get isPaused():Boolean
		{
			if (!_currentTrack) return false;
			
			return _currentTrack.isPaused;
		}
		
	/**
	 * playback interface
	 */
		override public function play( opts:Object=null ):void
		{
			if (!this.numChildren) return;
			
			createCurrentTrack();
			_subloops = (opts && opts.hasOwnProperty("subloops")) ? opts.subloops: _subloops;
			var params:Object = new Object();
			params.startTime = (opts && opts.hasOwnProperty("startTime")) ? opts.startTime : 0;
			params.loops = _subloops;
			params.volume = (opts && opts.hasOwnProperty("volume")) ? opts.volume : this.soundTransform.volume;
			params.panning = (opts && opts.hasOwnProperty("panning")) ? opts.panning : this.soundTransform.pan;
			
			
			_currentTrack.play( params );
			this.soundTransform.volume = params.volume;
			this.soundTransform.pan = params.panning;
			this.soundTransform = this.soundTransform;
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PLAY ) );
		}
		
		override public function resume():void
		{
			if (!this.numChildren || !_currentTrack) return;
			
			_currentTrack.resume();
			
			this.dispatchEvent( new SFXEvent( SFXEvent.RESUME ) );
		}
		
		override public function pause():void
		{
			if (!this.numChildren || !_currentTrack) return;
			
			_currentTrack.pause();
			
			this.dispatchEvent( new SFXEvent( SFXEvent.PAUSE ) );
		}
		
		override public function stop():void
		{
			destroyCurrentTrack();
			super.stop();
		}
		
		override public function seek( pos:Number ):void
		{
			if (!this.numChildren || !_currentTrack) return;
			
			_currentTrack.seek(pos);
		}
		
		override public function seekToPercent( per:Number ):void
		{
			if (!this.numChildren || !_currentTrack) return;
			
			_currentTrack.seekToPercent( per );
		}
/**
 * IDipsose interface
 */
		override public function reengage(...args):void
		{
			super.reengage( args.shift() );
			
			for each( var obj:ISFX in args )
			{
				this.addSFX( obj );
			}
		}
		
		override public function dispose():void
		{
			if(_disposed) return;
			this.destroyCurrentTrack();
			_currentTrack = undefined;
			_currentTrackPos = undefined;
			super.dispose();
		}
	}
}