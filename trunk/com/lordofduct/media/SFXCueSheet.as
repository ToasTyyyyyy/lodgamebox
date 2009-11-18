package com.lordofduct.media
{
	import com.lordofduct.events.SFXCueEvent;
	import com.lordofduct.events.SFXEvent;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	public class SFXCueSheet implements ISFXCue
	{
		private var _frameDispatcher:Shape = new Shape();
		
		private var _sfx:ISFX;
		private var _clasps:Array;
		
		private var _lastPos:Number = 0;
		private var _checkBackwards:Boolean;
		
		public function SFXCueSheet( sfx:ISFX=null, checkBack:Boolean=false )
		{
			_clasps = new Array();
			_checkBackwards = checkBack;
			
			this.registerSFX( sfx );
		}
		
/**
 * Properties
 */
		//the SFX object we are watching for cues
		public function get registeredSFX():ISFX { return _sfx; }
		
		//if the SFX is rewound at all, should the cue point just prior to the new time be dispatched
		public function get checkBackwards():Boolean { return _checkBackwards; }
		public function set checkBackwards(value:Boolean):void { _checkBackwards = value; }
/**
 * Methods
 */
		//register a new SFX object to be handled
		public function registerSFX(sfx:ISFX):void
		{
			this.onSFXStopListener();
			
			if(_sfx)
			{
				//remove event listeners
				//start events
				_sfx.removeEventListener( SFXEvent.PLAY, onSFXStartListener );
				_sfx.removeEventListener( SFXEvent.RESUME, onSFXStartListener );
				//stop events
				_sfx.removeEventListener( SFXEvent.PAUSE, onSFXStopListener );
				_sfx.removeEventListener( SFXEvent.STOP, onSFXStopListener );
				_sfx.removeEventListener( SFXEvent.COMPLETE, onSFXStopListener );
			}
			
			_sfx = sfx;
			
			if(_sfx)
			{
				//add event listeners
				//start events
				_sfx.addEventListener( SFXEvent.PLAY, onSFXStartListener, false, 0, true );
				_sfx.addEventListener( SFXEvent.RESUME, onSFXStartListener, false, 0, true );
				//stop events
				_sfx.addEventListener( SFXEvent.PAUSE, onSFXStopListener, false, 0, true );
				_sfx.addEventListener( SFXEvent.STOP, onSFXStopListener, false, 0, true );
				_sfx.addEventListener( SFXEvent.COMPLETE, onSFXStopListener, false, 0, true );
				
				if(_sfx.isPlaying) this.onSFXStartListener();
			}
		}
		
		//register a cue point, alias is its name, pos the time in milliseconds it occurs, and extras is any property of the SFX we should check if true
		//for example if a SFXPlaylist was passed we can pass { currentTrackPos:3 } to make sure that it only fires if the playlist is playing track 4
		public function registerCuePoint( alias:String, pos:int, extras:Object=null ):void
		{
			this.removeCuePoint( alias );
			var clasp:CuePointClasp = new CuePointClasp( alias, pos, extras );
			
			_clasps.push(clasp);
			_clasps.sortOn("position", Array.NUMERIC);
		}
		
		//remove a cue point of some alias name, alias names should always be unique!!!
		public function removeCuePoint( alias:String ):void
		{
			var clasp:CuePointClasp = this.getClaspByAlias( alias );
			
			if(!clasp) return;
			
			var index:int = _clasps.indexOf( clasp );
			
			if(index >= 0) _clasps.splice( index, 1 );
		}
		
	/**
	 * Event Listeners
	 */
		private function onSFXStartListener(e:SFXEvent=null):void
		{
			if(!_sfx) return;
			
			_lastPos = _sfx.position;
			
			_frameDispatcher.addEventListener( Event.ENTER_FRAME, checkIfCuePassed, false, 0, true );
		}
		
		private function onSFXStopListener(e:SFXEvent=null):void
		{	
			_frameDispatcher.removeEventListener( Event.ENTER_FRAME, checkIfCuePassed );
			
			if(_sfx) this.checkIfCuePassed();
			else _lastPos = 0;
		}
		
		private function checkIfCuePassed(e:Event=null):void
		{
			if(!_sfx)
			{
				this.onSFXStopListener();
				return;
			}
			
			var old:Number = _lastPos;
			var pos:Number = _sfx.position;
			_lastPos = pos;
			var clasp:CuePointClasp;
			var i:int;
			
			if(pos >= old)
			{
				for ( i = 0; i < _clasps.length; i++ )
				{
					clasp = _clasps[i] as CuePointClasp;
					
					if( old < clasp.position && pos >= clasp.position )
					{
						this.attemptToDispatchCue( clasp );
					}
				}
			} else if(_checkBackwards) {
				for ( i = 0; i < _clasps.length; i++ )
				{
					clasp = _clasps[i] as CuePointClasp;
					
					if( old > clasp.position && pos <= clasp.position )
					{
						if( i > 0 ) this.attemptToDispatchCue( _clasps[i - 1] );
						else _sfx.dispatchEvent( new SFXCueEvent( SFXCueEvent.CUE_MARK, null ) );
					}
				}
			}
		}
		
		private function getClaspByAlias( alias:String ):CuePointClasp
		{
			for each( var clasp:CuePointClasp in _clasps )
			{
				if(clasp.alias == alias) return clasp;
			}
			
			return null;
		}
		
		private function attemptToDispatchCue( clasp:CuePointClasp ):void
		{
			if(!_sfx) return;
			
			if(clasp.extras)
			{
				for( var prop in clasp.extras )
				{
					if(_sfx[prop] != clasp[prop]) return;
				}
			}
			
			_sfx.dispatchEvent( new SFXCueEvent( SFXCueEvent.CUE_MARK, clasp.alias ) );
		}
		
	/**
	 * IDisposable Interface
	 */
		public function reengage(...args):void
		{
			_clasps = new Array();
			
			this.registerSFX( args[0] );
		}
		
		public function dispose():void
		{
			this.registerSFX( null );
			_clasps = null;
		}
	}
}