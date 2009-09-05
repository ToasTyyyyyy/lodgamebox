package com.lordofduct.engines.ai
{
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.utils.Dictionary;
	
	final public class AStarEngine
	{
		private static var _inst:AStarEngine;
		
		public static function get instance():AStarEngine
		{
			if (!_inst) _inst=Singleton.gi(AStarEngine);
			return _inst;
		}
		
		public function AStarEngine()
		{	
			super();
			SingletonEnforcer.assertSingle(AStarEngine);
			
			this.heuristicId = Heuristics.DIST_MANHATTAN;
		}
		
/**
 * Class definition
 */
		private var _heuristic:Function;
		
		public function get heuristicId():String
		{
			return Heuristics.getIdFromMethod( _heuristic );
		}
		public function set heuristicId( value:String ):void
		{	
			_heuristic = Heuristics.getMethodFromId( value );
		}
		
		/**
		 * 
		 * 
		 * 		FIND PATH
		 * 
		 * 
		 */
		public function solve( map:IAiMap, start:IAiNode, goal:IAStarNode ):AiPathChain
		{
			var open:Array = new Array();
			var closed:Array = new Array();
			var idToPar:Dictionary = new Dictionary();
			var idToH:Dictionary = new Dictionary();
			var idToG:Dictionary = new Dictionary();
			
			var node:IAStarNode = start;
			idToH[ node.nodeId ] = _heuristic(start, goal);
			open.push(node);
			
			var solved:Boolean = false;
			
			// start
			while(!solved) {
				
				//TODO sort through dict
				open.sortOn("starF",Array.NUMERIC);
				if (open.length <= 0) break;
				node = open.shift();
				closed.push(node);
				
				// are we at the goal yet?
				if (node.nodeId == goal.nodeId) {
					// there!
					solved = true;
					break;
				}
				
				for each (var n:IAStarNode in map.getNeighbours( node )) {
					
					if (!hasElement(open,n) && !hasElement(closed,n)) {
						open.push(n);
						idToPar[n.nodeId] = node;
						idToH[n.nodeId] = _heuristic(n, goal);
						idToG[n.nodeId] += idToG[node.nodeId];
					} else {
						var newF:Number = idToG[n.nodeId] + idToG[node.nodeId] + idToH[n.nodeId];
						var prevF:Number = idToH[n.nodeId] + idToG[n.nodeId];
						if (newF < prevF) {
							idToPar[n.nodeId] = node;
							idToG[n.nodeId] += idToG[node.nodeId];
						}
					}
				}
			}

			// reached solution, is it actually solved?
			if (solved) {
				// an actual solution was found
				var solution:AiPathChain = new AiPathChain();
				// backtrack from the goal
				//node at this moment IS goal
				solution.appendNode(node);
				
				while (idToPar[node.nodeId] && idToPar[node.nodeId] != start) {
					node = idToPar[node.nodeId];
					solution.appendNode(node);
				}
				// lastly the start point
				solution.appendNode(start);
				
				return solution;
			} else {
				// No solution found
				return null;
			}
		}
		
		private function hasElement(a:Array, e:Object):Boolean
		{
			return Boolean( a.indexOf(e) >= 0 );
		}
	}
}