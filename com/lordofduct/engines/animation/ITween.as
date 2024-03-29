package com.lordofduct.engines.animation
{
	import com.lordofduct.util.IDisposable;
	
	import flash.events.IEventDispatcher;
	
	public interface ITween extends IEventDispatcher, IDisposable
	{
		//object being targeted
		function get target():Object
		//delay before animation starts
		function get delay():Number
		//duration of animation in seconds
		function get duration():Number
		//time passed in seconds
		function get passed():Number
		//percentage complete, value from 0 -> 1
		function get position():Number
		//the string describing the property being tweened
		function get property():String
		
		//used to update the animation, dt is time to pass in seconds
		//if complete, return true
		function update(dt:Number):Boolean
		function pause():void
		function resume():void
		function invert():void
	}
}