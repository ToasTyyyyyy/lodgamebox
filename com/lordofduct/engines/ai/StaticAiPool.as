package com.lordofduct.engines.ai
{
	import com.lordofduct.util.Assertions;
	
	import flash.utils.Dictionary;
	
	public class StaticAiPool implements IAiPool
	{
		private var _pool:Array;
		private var _neighbours:Dictionary;
		
		public function StaticAiPool( members:Array=null )
		{
			_pool = (members) members.slice() : new Array();
			_neighbours = new Dictionary();
		}
		
/**
 * Methods
 */
		public function addNode( ...args ):void
		{
			for each( var node:IAiNode in args )
			{
				if(!this.contains(node))
				{
					_pool.push(node);
					_neighbours[node] = new Array();
				}
			}
		}
		
		public function removeNode( ...args ):void
		{
			for each( var node:IAiNode in args )
			{
				var index:int = _pool.indexOf(node);
				Assertions.isTrue( index >= 0, "com.lordofduct.engine.ai::StaticAiPool - can not remove a node that is not a member of this pool." );
				_pool.splice(index,1);
				
				var arr:Array = _neighbours[node];
				
				for each( var neigh:IAiNode in arr )
				{
					this.removeNeighbourTangle( node, neigh );
				}
				
				_neighbours[node] = null;
			}
		}
		
		public function removeNeighbourTangle( node1:IAiNode, node2:IAiNode ):void
		{
			this.removeUniDirectionalNeighbour( node1, node2 );
			this.removeUniDirectionalNeighbour( node2, node1 );
		}
		
		public function removeUniDirectionalNeighbour( fromNode:IAiNode, toNode:IAiNode ):void
		{
			if(!this.contains(fromNode)) return;
			
			var arr:Array = _neighbours[fromNode];
			var index:int = arr.indexOf(toNode);
			if(index >= 0) arr.splice(index,1);
		}
		
		public function removeSeveralUniDirectionalNeighbours( fromNode:IAiNode, toNodes:Array ):void
		{
			for each( var toNode:IAiNode in toNodes )
			{
				this.removeUniDirectionalNeighbour( fromNode, toNode );
			}
		}
		
		public function setNeighbourTangle( node1:IAiNode, node2:IAiNode ):void
		{
			Assertions.isTrue( this.containsSeveral( node1, node2 ), "com.lordofduct.engine.ai::StaticAiPool - can not create neighbour tangle between nodes that aren't both members of this pool." );
			
			if(!this.contains(fromNode) || !this.contains(toNode)) return;
			
			this.setUniDirectionalNeighbour( node1, node2 );
			this.setUniDirectionalNeighbour( node2, node1 );
		}
		
		public function setUniDirectionalNeighbour( fromNode:IAiNode, toNode:IAiNode ):void
		{
			Assertions.isTrue( this.containsSeveral( fromNode, toNode ), "com.lordofduct.engine.ai::StaticAiPool - can not create neighbour tangle between nodes that aren't both members of this pool." );
			
			var arr:Array = _neighbours[fromNode];
			
			if(arr.indexOf(toNode) < 0) arr.push(toNode);
		}
		
		public function setSeveralUniDirectionalNeighbours( fromNode:IAiNode, toNodes:Array ):void
		{
			for each( var toNode:IAiNode in toNodes )
			{
				this.setUniDirectionalNeighbour( fromNode, toNode );
			}
		}
		
		
		
		
		//I Don't really know if I want to keep these next two methods...
		public function removeSeveralNeighbourTangles( nodes:Array ):void
		{
			for each( var fromNode:IAiNode in nodes )
			{
				var toNodes:Array = nodes.slice();
				toNodes.splice( toNodes.indexOf(fromNode), 1 );
				this.removeSeveralUniDirectionalNeighbours( fromNode, toNodes ); 
			}
		}
		
		public function setSeveralNeighbourTangles( nodes:Array ):void
		{
			for each( var fromNode:IAiNode in nodes )
			{
				var toNodes:Array = nodes.slice();
				toNodes.splice( toNodes.indexOf(fromNode), 1 );
				this.setSeveralUniDirectionalNeighbours( fromNode, toNodes ); 
			}
		}
		
	/**
	 * IAiPool Interface
	 */
		public function contains( node:IAiNode ):Boolean
		{
			return _pool.indexOf(node) >= 0;
		}
		
		public function containsSeveral( ...args ):Boolean
		{	
			for each( var node:IAiNode in args )
			{
				if(_pool.indexOf(node) < 0) return false;
			}
			
			return Boolean(args.length);
		}
		
		public function getNeighbours(node:IAiNode):Array
		{
			var arr:Array = _neighbours[node];
			
			return (arr) ? arr.slice() : null;
		}
		
		public function heuristicDistance(node1:IAiNode, node2:IAiNode):Number
		{
			//TODO!!!!!!
			
			return 0;
		}
	}
}