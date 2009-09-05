package com.lordofduct.engines.ai
{
	public interface IAiMap
	{
		function get mapId():String
		
		function getNeighbours( node:IAiNode ):Array
	}
}