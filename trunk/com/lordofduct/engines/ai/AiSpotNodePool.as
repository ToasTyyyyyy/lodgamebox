package com.lordofduct.engines.ai
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.IClonable;
	
	import flash.utils.Dictionary;
	
	public class AiSpotNodePool implements IAiNodePool
	{
		private var _pool:Array;
		private var _neighbours:Dictionary;
		private var _heur:Function;
		
		public function AiSpotNodePool( members:Array=null, heur:Function=null )
		{
			_pool = (members) members.slice() : new Array();
			_neighbours = new Dictionary();
			
			_heur = (heur is Function) ? heur : Heuristics.distEuclidianSquared;
		}
		
		public function get heuristicFunction():Function { return _heur; }
		public function set heuristicFunction(value:Function):void { if(value is Function) _heur = value; }
		
	/**
	 * IAiNodePool Interface
	 */
		public function get numMembers():int { return _pool.length; }
		
		public function get members():Array { return _pool.slice(); }
		
/**
 * Methods
 */
		public function addNode( ...args ):void
		{
			for each( var node:IAiSpotNode in args )
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
			for each( var node:IAiSpotNode in args )
			{
				var index:int = _pool.indexOf(node);
				Assertions.isTrue( index >= 0, "com.lordofduct.engine.ai::StaticAiPool - can not remove a node that is not a member of this pool." );
				_pool.splice(index,1);
				
				var arr:Array = _neighbours[node];
				
				for each( var neigh:IAiSpotNode in arr )
				{
					this.removeNeighbourTangle( node, neigh );
				}
				
				_neighbours[node] = null;
			}
		}
		
		public function removeNeighbourTangle( node1:IAiSpotNode, node2:IAiSpotNode ):void
		{
			this.removeUniDirectionalNeighbour( node1, node2 );
			this.removeUniDirectionalNeighbour( node2, node1 );
		}
		
		public function removeUniDirectionalNeighbour( fromNode:IAiSpotNode, toNode:IAiSpotNode ):void
		{
			if(!this.contains(fromNode)) return;
			
			var arr:Array = _neighbours[fromNode];
			var index:int = arr.indexOf(toNode);
			if(index >= 0) arr.splice(index,1);
		}
		
		public function removeSeveralUniDirectionalNeighbours( fromNode:IAiSpotNode, toNodes:Array ):void
		{
			for each( var toNode:IAiSpotNode in toNodes )
			{
				this.removeUniDirectionalNeighbour( fromNode, toNode );
			}
		}
		
		public function setNeighbourTangle( node1:IAiSpotNode, node2:IAiSpotNode ):void
		{
			Assertions.isTrue( this.containsSeveral( node1, node2 ), "com.lordofduct.engine.ai::StaticAiPool - can not create neighbour tangle between nodes that aren't both members of this pool." );
			
			if(!this.contains(fromNode) || !this.contains(toNode)) return;
			
			this.setUniDirectionalNeighbour( node1, node2 );
			this.setUniDirectionalNeighbour( node2, node1 );
		}
		
		public function setUniDirectionalNeighbour( fromNode:IAiSpotNode, toNode:IAiSpotNode ):void
		{
			Assertions.isTrue( this.containsSeveral( fromNode, toNode ), "com.lordofduct.engine.ai::StaticAiPool - can not create neighbour tangle between nodes that aren't both members of this pool." );
			
			var arr:Array = _neighbours[fromNode];
			
			if(arr.indexOf(toNode) < 0) arr.push(toNode);
		}
		
		public function setSeveralUniDirectionalNeighbours( fromNode:IAiSpotNode, toNodes:Array ):void
		{
			for each( var toNode:IAiSpotNode in toNodes )
			{
				this.setUniDirectionalNeighbour( fromNode, toNode );
			}
		}
		
		
		
		
		//I Don't really know if I want to keep these next two methods...
		public function removeSeveralNeighbourTangles( nodes:Array ):void
		{
			for each( var fromNode:IAiSpotNode in nodes )
			{
				var toNodes:Array = nodes.slice();
				toNodes.splice( toNodes.indexOf(fromNode), 1 );
				this.removeSeveralUniDirectionalNeighbours( fromNode, toNodes ); 
			}
		}
		
		public function setSeveralNeighbourTangles( nodes:Array ):void
		{
			for each( var fromNode:IAiSpotNode in nodes )
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
			for each( var node:IAiSpotNode in args )
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
			var n1:IAiSpotNode = node1 as IAiSpotNode;
			var n2:IAiSpotNode = node2 as IAiSpotNode;
			
			if(!n1 || !n2) return Number.POSITIVE_INFINITY;
			
			return _heur( n1.x, n1.y, n2.x, n2.y );
		}
		
	/**
	 * IClonable Interface
	 */
		public function clone():*
		{
			var nodes:Array = this.members;
			
			var pool:AiSpotNodePool = new AiSpotNodePool( nodes, this.heuristicFunction );
			
			for each( var node:IAiSpotNode in nodes )
			{
				var neigh:Array = this.getNeighbours( node );
				pool.setSeveralUniDirectionalNeighbours( node, neigh );
			}
			
			return pool;
		}
		
		public function copy(obj:*):void
		{
			var pool:AiSpotNodePool = obj as AiSpotNodePool;
			if(!obj) return;
			
			_pool = pool.members;
			_neighbours = new Dictionary();
			_heur = pool.heuristicFunction;
			
			for each( var node:IAiSpotNode in _pool )
			{
				var neigh:Array = pool.getNeighbours( node );
				pool.setSeveralUniDirectionalNeighbours( node, neigh );
			}
		}
	}
}