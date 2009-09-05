/**
 * ISFX - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Interface written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This is the interface to all ISFX objects. This is a group of classes that 
 * assists in controlling Sound a multitude of ways. The class hierarchy is self
 * consuming in that nearly all ISFX objects (except for SFXSound) can contain 
 * any other ISFX object. Thusly creating daisy chains of different objects to 
 * create long and interesting effects.
 * 
 * WARNING - by daisy chaining ISFX objects inside of each other some unexpected 
 * issues may arise. Do this at your own risk knowing there is NO documentation 
 * on the effects that may occur. You may want to read through all the code for 
 * each ISFX object to get an idea of what to expect. Or not, test, see what happens!
 */
package com.lordofduct.media
{
	import com.lordofduct.util.IDisposable;
	import com.lordofduct.util.IIdentifiable;
	
	import flash.events.IEventDispatcher;
	import flash.media.SoundTransform;
	
	public interface ISFX extends IEventDispatcher, IDisposable, IIdentifiable
	{
		function get numChildren():int
		function get length():Number
		function get position():Number
		function get isPlaying():Boolean
		function get isPaused():Boolean
		
	/**
	 * playback interface
	 */
		function play( opts:Object=null ):void
		function resume():void
		function pause():void
		function stop():void
		function seek( pos:Number ):void
		function seekToPercent( per:Number ):void
		
	/**
	 * SoundTransform interface
	 */
		function get soundTransform():SoundTransform
		function set soundTransform( value:SoundTransform ):void
		
		function get volume():Number
		function set volume( value:Number ):void
		
		function get panning():Number
		function set panning( value:Number ):void
		
		function mute():void
	}
}