package com.lordofduct.ui
{
	public interface IResizablePopWindow extends IPopWindow
	{
		function get windowWidth():Number
		function set windowWidth(value:Number):void
		
		function get windowHeight():Number
		function set windowHeight(value:Number):void
		
		function setWindowSize( w:Number, h:Number ):void
	}
}