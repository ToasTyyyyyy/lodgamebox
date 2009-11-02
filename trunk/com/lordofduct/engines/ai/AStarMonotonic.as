package com.lordofduct.engines.ai
{
	import flash.utils.Dictionary;
	
	public class AStarMonotonic
	{
		private var _pool:IAiNodePool;
		private var _start:IAiNode;
		private var _goal:IAiNode;
		private var _assumeWeight:Boolean = false;
		
		//accessible for static functions
		private var $open:Array = new Array();//open nodes that can be travelled onto
		private var $closed:Array = new Array();//nodes checked for travel
		private var $g_score:Dictionary = new Dictionary();//the distance and weight from start to current
		private var $h_score:Dictionary = new Dictionary();//the distance from current to goal
		private var $f_score:Dictionary = new Dictionary();//the sum of g and h
		private var $parent_list:Dictionary = new Dictionary();//a reference to the node that brings you to current
		private var $resolved:Boolean = false;
		
		public function AStarMonotonic(pool:IAINodePool, startNode:IAiNode, goalNode:IAiNode, assmWght:Boolean=true )
		{
			if(!pool.containsSeveral(start, goal)) throw new Error("com.lordofduct.engines.ai::AStarMonotonic - pool must contain both start point and goal");
			
			_pool = pool;
			_start = startNode;
			_goal = goalNode;
			_assumeWeight = assmWght;
			
			AStarMonotonic.reduce( this );
		}
		
/**
 * Properties
 */
		public function get aiPool():IAiNodePool { return _pool; }
		public function get start():IAiNode { return _start; }
		public function get goal():IAiNode { return _goal; }
		public function get assumeWeight():Boolean { return _assumeWeight; }
		
		public function get reduced():Boolean { return this.$resolved; }
		
		public function get latest_f_score():Number
		{
			return (this.$closed.length) ? this.$f_score[ this.$closed[ this.$closed.length - 1 ] ] : 0;
		}
	/**
	 * Private Static Accessible Interface
	 */
		
/**
 * Methods
 */
		public function constructPath():Array
		{
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
	 * Private Static Accessible Interface
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
					clasp.$resolved = true;
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
				
				if(clasp.$resolved) return clasp;
				
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
					clasp.$resolved = true;
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


//reduce function with out AStarMonoClasp dependency
/*
		static public function reduce( pool:IAiNodePool, start:IAiNode, goal:IAiNode, assumeWeight:Boolean=true ):Array
		{
			if(!pool.containsSeveral(start, goal)) return null;
			
			var open:Array = new Array();//open nodes that can be travelled onto
			var closed:Array = new Array();//nodes checked for travel
			var g_score:Dictionary = new Dictionary();//the distance and weight from start to current
			var h_score:Dictionary = new Dictionary();//the distance from current to goal
			var f_score:Dictionary = new Dictionary();//the sum of g and h
			var parent_list:Dictionary = new Dictionary();//a reference to the node that brings you to current
			
			//set start values
			g_score[start] = (assumeWeight) ? start.weight : 0;//NOTE - WEIGHT CHECK
			h_score[start] = pool.heuristicDistance( start, goal );
			f_score[start] = g_score[start] + h_score[start];
			
			open.push( start );
			
			while(open.length)
			{
				//find smallest f score in open list
				var xnode:IAiNode = getSmallestF(open, f_score);
				
				//if at goal, we're finished
				if(xnode == goal) return constructPath(parent_list, start, goal);
				
				open.splice( open.indexOf(xnode), 1 );
				closed.push(xnode);
				
				var neighbours:Array = pool.getNeighbours( xnode );
				
				for each( var ynode:IAiNode in neighbours )
				{
					if(closed.indexOf(ynode) >= 0) continue;
					
					var tentative_g_score:Number = g_score[xnode] + pool.heuristicDistance( xnode, ynode );
					if(assumeWeight) tentative_g_score += ynode.weight;//NOTE - WEIGHT CHECK
					
					if(open.indexOf(ynode) < 0)
					{
						parent_list[ynode] = xnode;
						g_score[ynode] = tentative_g_score;
						h_score[ynode] = pool.heuristicDistance( ynode, goal );
						f_score[ynode] = g_score[ynode] + h_score[ynode];
						open.push(ynode);
					} else if( tentative_g_score < g_score[ynode] )
					{
						parent_list[ynode] = xnode;
						g_score[ynode] = tentative_g_score;
						f_score[ynode] = g_score[ynode] + h_score[ynode];
					}
				}
			}
			
			return null;//failed
		}
		
		private static function constructPath( parent_list:Dictionary, start:IAiNode, goal:IAiNode ):Array
		{
			var node:IAiNode = goal;
			var arr:Array = [ node ];
			
			while( parent_list[node] != start )
			{
				node = parent_list[node];
				arr.push( node );
			}
			
			return arr;
		}
		
		private static function getSmallestF( list:Array, f_score:Dictionary ):IAiNode
		{
			var smallest:IAiNode;
			var f:Number = Number.POSITIVE_INFINITY;
			
			for each( var node:IAiNode in list )
			{
				if(f_score[node] < f)
				{
					f = f_score[node];
					smallest = node;
				}
			}
			
			return smallest;
		}
*/