package com.lordofduct.engines.ai
{
	import flash.utils.Dictionary;
	
	public class AStarMonotonic
	{
		private var _pool:IAiNodePool;
		private var _start:IAiNode;
		private var _goal:IAiNode;
		private var _assumeWeight:Boolean = false;
		private var _reduced:Boolean = false;
		
		//accessible for static functions
		private var $open:Array;//open nodes that can be travelled onto
		private var $closed:Array;//nodes checked for travel
		private var $g_score:Dictionary;//the distance and weight from start to current
		private var $h_score:Dictionary;//the distance from current to goal
		private var $f_score:Dictionary;//the sum of g and h
		private var $parent_list:Dictionary;//a reference to the node that brings you to current
		
		public function AStarMonotonic(pool:IAINodePool, startNode:IAiNode, goalNode:IAiNode, assmWght:Boolean=true )
		{
			if(!pool.containsSeveral(start, goal)) throw new Error("com.lordofduct.engines.ai::AStarMonotonic - pool must contain both start point and goal");
			
			_pool = pool;
			_start = startNode;
			_goal = goalNode;
			_assumeWeight = assmWght;
		}
		
/**
 * Properties
 */
		public function get aiPool():IAiNodePool { return _pool; }
		public function get start():IAiNode { return _start; }
		public function get goal():IAiNode { return _goal; }
		
		public function get assumeWeight():Boolean { return _assumeWeight; }
		public function set assumeWeight(value:Boolean):void
		{
			if(value != _assumeWeight) _reduced = false;
			
			_assumeWeight = value;
		}
		
		public function get reduced():Boolean { return _reduced; }
		public function set reduced(value:Boolean):void { _reduced = value; }
		
		public function get latest_f_score():Number
		{
			return (this.$closed.length) ? this.$f_score[ this.$closed[ this.$closed.length - 1 ] ] : 0;
		}
	/**
	 * Protected Static Accessible Interface
	 */
		
/**
 * Methods
 */
		public function constructPath():Array
		{
			//if this wasn't reduced, don't do it!
			if(!this.reduced) return null;
			
			var node:IAiNode = this.goal;
			var arr:Array = [ node ];
			
			while( this.$parent_list[node] != this.start )
			{
				node = this.$parent_list[node];
				arr.push( node );
			}
			
			return arr;
		}
		
		public function reduce():Boolean
		{
			return AStarMonotonic.reduce( this );
		}
	/**
	 * Protected Static Accessible Interface
	 */
		private function sortOpenList():void
		{
			this.$open.sort(sortHelper);
		}
		
		private function pullSmallestOpenF():IAiNode
		{
			this.$open.sort(sortHelper);
			
			return this.$open.shift();
		}
		
		private function sortHelper( a:IAiNode, b:IAiNode ):int
		{
			var af:Number = this.$f_score[a];
			var bf:Number = this.$f_score[b];
			
			if(af > bf) return 1;
			else if(af < bf) return -1;
			else return 0;
		}
		
/**
 * Static Interface
 */
		static public function reduce( clasp:AStarMonotonic ):Boolean
		{
			clasp.reduced = false;
			clasp.$closed = new Array();
			clasp.$open = new Array();
			clasp.$f_score = new Dictionary();
			clasp.$g_score = new Dictionary();
			clasp.$h_score = new Dictionary();
			clasp.$parent_list = new Dictionary();
			
			var pool:IAiNodePool = clasp.aiPool;
			var start:IAiNode = clasp.start;
			var goal:IAiNode = clasp.goal;
			var assumeWeight:Boolean = clasp.assumeWeight;
			
			//set start values
			clasp.$g_score[start] = (assumeWeight) ? start.weight : 0;//NOTE - WEIGHT CHECK
			clasp.$h_score[start] = pool.heuristicDistance( start, goal );
			clasp.$f_score[start] = clasp.$g_score[start] + clasp.$h_score[start];
			
			clasp.$open.push( start );
			
			while(clasp.$open.length)
			{
				//find smallest f score in open list
				var xnode:IAiNode = clasp.pullSmallestOpenF();
				
				//if at goal, we're finished
				if(xnode == goal)
				{
					clasp.reduced = true;
					return true;
				}
				
				clasp.$closed.push(xnode);
				
				var neighbours:Array = pool.getNeighbours( xnode );
				
				for each( var ynode:IAiNode in neighbours )
				{
					if(clasp.$closed.indexOf(ynode) >= 0) continue;
					
					var tentative_g_score:Number = clasp.$g_score[xnode] + pool.heuristicDistance( xnode, ynode );
					if(assumeWeight) tentative_g_score += ynode.weight;//NOTE - WEIGHT CHECK
					
					if(clasp.$open.indexOf(ynode) < 0)
					{
						clasp.$parent_list[ynode] = xnode;
						clasp.$g_score[ynode] = tentative_g_score;
						clasp.$h_score[ynode] = pool.heuristicDistance( ynode, goal );
						clasp.$f_score[ynode] = clasp.$g_score[ynode] + clasp.$h_score[ynode];
						clasp.$open.push(ynode);
					} else if( tentative_g_score < clasp.$g_score[ynode] )
					{
						clasp.$parent_list[ynode] = xnode;
						clasp.$g_score[ynode] = tentative_g_score;
						clasp.$f_score[ynode] = clasp.$g_score[ynode] + clasp.$h_score[ynode];
					}
				}
			}
			
			return false;//failed
		}
		
		static public function reduceGoal( pool:IAiNodePool, start:IAiNode, goal:IAiNode, assumeWeight:Boolean=true ):AStarMonotonic
		{
			if(!pool.containsSeveral(start, goal)) return null;
			
			var clasp:AStarMonotonic = new AStarMonotonic( pool, start, goal, assumeWeight );
			
			return (AStarMonotonic.reduce( clasp )) ? clasp : null;
		}
		
		static public function reduceMultipleGoals( pool:IAiNodePool, start:IAiNode, goals:Array, assumeWeight:Boolean=false ):AStarMonotonic
		{
			goals = goals.slice();
			if(!pool.contains(start)) return null;
			
			var goal:IAiNode;
			var clasp:AStarMonotonic;
			var clasps:Array = new Array();
			
			for( var i:int = 0; i < goals.length; i++ )
			{
				goal = goals[i] as IAiNode;
				
				if(goal && pool.contains(goal))
				{
					clasp = new AStarMonotonic( pool, start, goal, assumeWeight );
					clasp.$g_score[start] = (assumeWeight) ? start.weight : 0;//NOTE - WEIGHT CHECK
					clasp.$h_score[start] = pool.heuristicDistance( start, goal );
					clasp.$f_score[start] = clasp.$g_score[start] + clasp.$h_score[start];
					clasp.$open.push(start);
					clasps.push( clasp );
				}
			}
			
			while(clasps.length)
			{
				clasps.sortOn("latest_f_score", Array.NUMERIC);
				clasp = clasp[0];
				
				if(clasp.reduced) return clasp;
				
				if(!clasp.$open.length)
				{
					clasps.splice(clasps.indexOf(clasp), 1);
					continue;
				}
				
				goal = clasp.goal;
				
				var xnode:IAiNode = clasp.pullSmallestOpenF();
				clasp.$closed.push(xnode);
				
				if(xnode == goal)
				{	
					clasp.reduced = true;
					continue;
				}
				
				var neighbours:Array = pool.getNeighbours( xnode );
				
				for each( var ynode:IAiNode in neighbours )
				{
					if(clasp.$closed.indexOf(ynode) >= 0) continue;
					
					var tentative_g_score:Number = clasp.$g_score[xnode] + pool.heuristicDistance( xnode, ynode );
					if(assumeWeight) tentative_g_score += ynode.weight;//NOTE - WEIGHT CHECK
					
					if(clasp.$open.indexOf(ynode) < 0)
					{
						clasp.$parent_list[ynode] = xnode;
						clasp.$g_score[ynode] = tentative_g_score;
						clasp.$h_score[ynode] = pool.heuristicDistance( ynode, goal );
						clasp.$f_score[ynode] = clasp.$g_score[ynode] + clasp.$h_score[ynode];
						clasp.$open.push(ynode);
					} else if( tentative_g_score < clasp.$g_score[ynode] )
					{
						clasp.$parent_list[ynode] = xnode;
						clasp.$g_score[ynode] = tentative_g_score;
						clasp.$f_score[ynode] = clasp.$g_score[ynode] + clasp.$h_score[ynode];
					}
				}
			}
			
			return null;//failed
		}
	}
}