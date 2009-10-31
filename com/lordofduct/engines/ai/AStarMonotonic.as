package com.lordofduct.engines.ai
{
	import flash.utils.Dictionary;
	
	public class AStarMonotonic
	{
		public function AStarMonotonic()
		{
			
		}
		
/**
 * Static Interface
 */
		static public function reduce( pool:IAiPool, start:IAiNode, goal:IAiNode, assumeWeight:Boolean=true ):Array
		{
			if(!pool.containsSeveral(start, goal)) return null;
			
			var clasp:AStarMonoClasp = new AStarMonoClasp( start, goal );
			
			//set start values
			clasp.g_score[start] = (assumeWeight) ? start.weight : 0;//NOTE - WEIGHT CHECK
			clasp.h_score[start] = pool.heuristicDistance( start, goal );
			clasp.f_score[start] = clasp.g_score[start] + clasp.h_score[start];
			
			clasp.open.push( start );
			
			while(clasp.open.length)
			{
				//find smallest f score in open list
				var xnode:IAiNode = clasp.pullSmallestOpenF();
				
				//if at goal, we're finished
				if(xnode == goal) return clasp.constructPath();
				
				clasp.closed.push(xnode);
				
				var neighbours:Array = pool.getNeighbours( xnode );
				
				for each( var ynode:IAiNode in neighbours )
				{
					if(clasp.closed.indexOf(ynode) >= 0) continue;
					
					var tentative_g_score:Number = clasp.g_score[xnode] + pool.heuristicDistance( xnode, ynode );
					if(assumeWeight) tentative_g_score += ynode.weight;//NOTE - WEIGHT CHECK
					
					if(clasp.open.indexOf(ynode) < 0)
					{
						clasp.parent_list[ynode] = xnode;
						clasp.g_score[ynode] = tentative_g_score;
						clasp.h_score[ynode] = pool.heuristicDistance( ynode, goal );
						clasp.f_score[ynode] = clasp.g_score[ynode] + clasp.h_score[ynode];
						clasp.open.push(ynode);
					} else if( tentative_g_score < clasp.g_score[ynode] )
					{
						clasp.parent_list[ynode] = xnode;
						clasp.g_score[ynode] = tentative_g_score;
						clasp.f_score[ynode] = clasp.g_score[ynode] + clasp.h_score[ynode];
					}
				}
			}
			
			return null;//failed
		}
		
		static public function reduceMultipleGoals( pool:IAiPool, start:IAiNode, goals:Array, assumeWeight:Boolean=false ):Array
		{
			goals = goals.slice();
			if(!pool.contains(start)) return null;
			
			var goal:IAiNode;
			var clasp:AStarMonoClasp;
			var clasps:Array = new Array();
			
			for( var i:int = 0; i < goals.length; i++ )
			{
				goal = goals[i] as IAiNode;
				
				if(goal && pool.contains(goal))
				{
					clasp = new AStarMonoClasp( start, goal );
					clasp.g_score[start] = (assumeWeight) ? start.weight : 0;//NOTE - WEIGHT CHECK
					clasp.h_score[start] = pool.heuristicDistance( start, goal );
					clasp.f_score[start] = clasp.g_score[start] + clasp.h_score[start];
					clasp.open.push(start);
					clasps.push( clasp );
				}
			}
			
			while(clasps.length)
			{
				clasps.sortOn("clasp_f_score", Array.NUMERIC);
				clasp = clasp[0];
				
				if(clasp.resolved) return clasp.constructPath();
				
				if(!clasp.open.length)
				{
					clasps.splice(clasps.indexOf(clasp), 1);
					continue;
				}
				
				goal = clasp.goal;
				
				var xnode:IAiNode = clasp.pullSmallestOpenF();
				clasp.closed.push(xnode);
				
				if(xnode == goal)
				{	
					clasp.resolved = true;
					continue;
				}
				
				var neighbours:Array = pool.getNeighbours( xnode );
				
				for each( var ynode:IAiNode in neighbours )
				{
					if(clasp.closed.indexOf(ynode) >= 0) continue;
					
					var tentative_g_score:Number = clasp.g_score[xnode] + pool.heuristicDistance( xnode, ynode );
					if(assumeWeight) tentative_g_score += ynode.weight;//NOTE - WEIGHT CHECK
					
					if(clasp.open.indexOf(ynode) < 0)
					{
						clasp.parent_list[ynode] = xnode;
						clasp.g_score[ynode] = tentative_g_score;
						clasp.h_score[ynode] = pool.heuristicDistance( ynode, goal );
						clasp.f_score[ynode] = clasp.g_score[ynode] + clasp.h_score[ynode];
						clasp.open.push(ynode);
					} else if( tentative_g_score < clasp.g_score[ynode] )
					{
						clasp.parent_list[ynode] = xnode;
						clasp.g_score[ynode] = tentative_g_score;
						clasp.f_score[ynode] = clasp.g_score[ynode] + clasp.h_score[ynode];
					}
				}
			}
			
			return null;//failed
		}
	}
}

import com.lordofduct.engines.ai.IAiNode;
import flash.utils.Dictionary;

class AStarMonoClasp
{
	public var start:IAiNode;
	public var goal:IAiNode;
	
	public var open:Array = new Array();//open nodes that can be travelled onto
	public var closed:Array = new Array();//nodes checked for travel
	public var g_score:Dictionary = new Dictionary();//the distance and weight from start to current
	public var h_score:Dictionary = new Dictionary();//the distance from current to goal
	public var f_score:Dictionary = new Dictionary();//the sum of g and h
	public var parent_list:Dictionary = new Dictionary();//a reference to the node that brings you to current
	
	public var resolved:Boolean = false;
	
	public function AStarMonoClasp(startNode:IAiNode, goalNode:IAiNode)
	{
		start = startNode;
		goal = goalNode;
	}
	
	public function get clasp_f_score():Number
	{
		return (closed.length) ? f_score[closed[closed.length - 1]] : 0;
	}
	
	public function constructPath():Array
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
	
	public function sortOpenList():void
	{
		open.sort(sortHelper);
	}
	
	public function pullSmallestOpenF():IAiNode
	{
		open.sort(sortHelper);
		
		return open.shift();
	}
	
	private function sortHelper( a:IAiNode, b:IAiNode ):int
	{
		var af:Number = f_score[a];
		var bf:Number = f_score[b];
		
		if(af > bf) return 1;
		else if(af < bf) return -1;
		else return 0;
	}
}












//reduce function with out AStarMonoClasp dependency
/*
		static public function reduce( pool:IAiPool, start:IAiNode, goal:IAiNode, assumeWeight:Boolean=true ):Array
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
				
				var neighbours:Array = pool.getNeighbours( clasp.aiNode );
				
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