package com.lordofduct.media
{
	import com.lordofduct.util.IDisposable;
	
	public interface ISFXCue extends IDisposable
	{
		function get checkBackwards():Boolean
		function set checkBackwards(value:Boolean):void
		
		function get registeredSFX():ISFX
		
		function registerSFX( sfx:ISFX ):void
	}
}