package com.lordofduct.engines.ai
{
	import com.lordofduct.util.IClonable;
	
	public interface IAiNodePool extends IClonable
	{
		function get numMembers():int
		function get members():Array
		
		function contains( node:IAiNode ):Boolean
		
		function containsSeveral( ...args ):Boolean
		
		function getNeighbours( node:IAiNode ):Array
		
		function heuristicDistance( node1:IAiNode, node2:IAiNode ):Number
	}
}