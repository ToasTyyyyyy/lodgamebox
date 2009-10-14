package com.lordofduct.engines.animation
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	public interface IChildTransition extends ITween
	{
		function get endChild():DisplayObject
		function get startChild():DisplayObject
		function get relatedContainer():DisplayObjectContainer
	}
}