package com.lordofduct.engines.ai
{
	import com.lordofduct.util.IClonable;
	import com.lordofduct.util.IDisposable;
	
	public interface IAiNode extends IClonable
	{
		function get nodeId():String
		
		function get x():Number
		function get y():Number
		
		function get weight():Number
	}
}