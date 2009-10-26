package com.lordofduct.engines.ai
{
	public interface IAiPool
	{
		function contains( node:IAiNode ):Boolean
		
		function containsSeveral( ...args ):Boolean
		
		function getNeighbours( node:IAiNode ):Array
		
		function heuristicDistance( node1:IAiNode, node2:IAiNode ):Number
	}
}