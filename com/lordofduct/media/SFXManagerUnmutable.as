/**
 * SFXManager - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * Used to manage ISFX objects creating global accessors to any ISFX object 
 * passed to it. It also supplies a hand full of factory methods for generating 
 * different ISFX objects.
 * 
 * When removing ISFX objects nothing is changed about them. They are just removed 
 * from the Manager instance. If they happen to be playing upon removal, you need 
 * to stop their playback on your own. Removal methods assume that you have another 
 * reference of the objects elsewhere.
 * 
 * Destroy methods on the other hand access the IDisposable interface of the ISFX 
 * object and dispose of it before removing the object. This will cause the object 
 * to completely hault all actions.
 * 
 * 
 * Bar in mind, ISFX objects are ALL disposable. They are not meant to be kept alive 
 * for very long periods of time. Destroy them when you don't need them and create a new 
 * one when you need it again. The manager here is meant to make the process easier on 
 * the programmer. For instance, a SFXPlaylist should not contain a very long playlist of 
 * hundreds songs. This would be memory intensive on the application when the end-user 
 * probably is only utilizing a small handful of those sounds at a time. Instead you can 
 * use the URIPlaylist to describe the locations of these songs on the internet and id information 
 * along with other things. Then as playlists are generated and needed by the end-user you 
 * create temporary ISFXPlaylists that play these songs. Once they are done, destroy the 
 * SFXPlaylist again and hold onto the URIPlaylist until tracks from it are needed yet again.
 */
package com.lordofduct.media
{
	import com.lordofduct.events.SFXEvent;
	import com.lordofduct.util.IDisposable;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.media.SoundLoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public dynamic class SFXManagerUnmutable extends Proxy
	{
		/**
		 * Enforce that this is a Singleton
		 * Utilizes the Guttershark method of Singleton Enforcement. Alter this section 
		 * to change the Singleton enforcement method.
		 */
		private static var _inst:SFXManagerUnmutable;
		
		public static function get instance():SFXManagerUnmutable
		{
			if (!_inst) _inst=SingletonEnforcer.gi(SFXManagerUnmutable);
			return _inst;
		}
		
		public function SFXManagerUnmutable()
		{	
			SingletonEnforcer.assertSingle(SFXManagerUnmutable);
		}
		
/**
 * Class definition
 */
		private var _idToSFX:Dictionary = new Dictionary();
		private var _bgChannels:Array = new Array();
		
/**
 * Properties
 */
/**
 * Methods
 */
		/**
		 * Add an ISFX object. The id you can reference it by is the value present 
		 * in its 'id' property.
		 */
		public function addSFX( sfx:ISFX ):void
		{
			_idToSFX[sfx.id] = sfx;
		}
		
		/**
		 * Add an ISFX object independent of the value in it's 'id' property
		 */
		public function addSFXById( idx:String, sfx:ISFX ):void
		{
			sfx.id = idx;
			_idToSFX[idx] = sfx;
		}
		
		public function removeSFX( sfx:ISFX ):void
		{
			if(!this.isManagingSFX(sfx.id)) return;
			
			delete _idToSFX[sfx.id];
		}
		
		public function removeSFXById( idx:String ):void
		{
			var sfx:ISFX = _idToSFX[idx];
			if(!sfx) return;
			
			delete _idToSFX[ idx ];
		}
		
		public function removeAll():void
		{
			_idToSFX = new Dictionary();
		}
		
		public function destroySFX( sfx:ISFX ):void
		{
			if(!this.isManagingSFX(sfx.id)) return;
			
			delete _idToSFX[sfx.id];
			sfx.dispose();
		}
		
		public function destroySFXById( idx:String ):void
		{
			var sfx:ISFX = _idToSFX[ idx ];
			if(!sfx) return;
			
			delete _idToSFX[idx];
			
			if (sfx) sfx.dispose();
		}
		
		public function destroyAll():void
		{
			for each( var sfx:ISFX in _idToSFX )
			{
				sfx.dispose();
			}
			
			removeAll();
		}
		
		public function stopAll():void
		{
			for each( var sfx:ISFX in _idToSFX )
			{
				sfx.stop();
			}
		}
		
		public function getSFX( idx:String ):ISFX
		{
			return _idToSFX[ idx ];
		}
		
		public function isManagingSFX( idx:String ):Boolean
		{
			return Boolean( _idToSFX[ idx ] );
		}
		
	/**
	 * Background Music Channels
	 */
		public function setBackgroundChannel( sfx:ISFX, channel:int=0 ):void
		{
			var old:ISFX = _bgChannels[channel];
			_bgChannels[channel] = sfx;
			
			if(old && old != sfx)
			{
				old.stop();
			}
		}
		
		public function getBackgroundChannel( channel:int=0 ):ISFX
		{
			return _bgChannels[channel];
		}
		
	/**
	 * Factory methods
	 * 
	 * these methods are used to create objects as accessible properties of this manager. 
	 * By supplying an "id" to any of these methods you can then access said ISFX Object 
	 * by calling SFXManager.instance.nameOfId
	 */
		public function createSFXSound( idx:String, snd:*, context:SoundLoaderContext=null ):void
		{
			var sfx:SFXSound = new SFXSound( idx, snd, context );
			addSFX( sfx );
		}
		
		public function createSFXObject( idx:String, snd:* ):void
		{
			var sfx:SFXObject = new SFXObject( idx, snd );
			addSFX( sfx );
		}
		
		public function createSFXGroup( idx:String ):void
		{
			var sfx:SFXGroup = new SFXGroup( idx );
			addSFX( sfx );
		}
		
		public function createSFXPlaylist( idx:String ):void
		{
			var sfx:SFXPlaylist = new SFXPlaylist( idx );
			addSFX( sfx );
		}
		
		public function createSFXPlaylistFromURIPlaylist( pl:URIPlaylist ):void
		{
			var sfx:SFXPlaylist = new SFXPlaylist( pl.id );
			for each( var item:* in pl )
			{
				var sound:SFXSound = new SFXSound( item.id, item.uri, item.context as SoundLoaderContext );
				sfx.addSFX( sound );
			}
			
			addSFX( sfx );
		}
		
		public function createSFXNoise( idx:String, snd:*, context:SoundLoaderContext=null ):void
		{
			var sfx:SFXNoise = new SFXNoise( idx, snd, context );
			addSFX( sfx );
		}
		
	/**
	 * Private methods
	 */
		
		
/**
 * Proxy overrides
 */
		flash_proxy override function callProperty(methodName:*, ...args):*
		{
			trace("gigo.media::SFXManager - Method {"+methodName+"} not found.");
			return null;
		}
		
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			var sfx:IDisposable = _idToSFX[ name ];
			var bool:Boolean = delete _idToSFX[name];
			if (sfx) sfx.dispose();
			return bool;
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			return _idToSFX[name];
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			return Boolean( _idToSFX[name] );
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			trace("gigo.media::SFXManager - Property {" + name + "} can not be set, create properties using the factory methods supplied.");
		}
	}
}