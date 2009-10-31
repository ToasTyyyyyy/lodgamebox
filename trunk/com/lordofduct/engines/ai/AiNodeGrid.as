package com.lordofduct.engines.ai
{
	import flash.geom.Point;
	
	public class AiNodeGrid implements IAiNodePool
	{
		private var _grid:Array;
		private var _rows:int = 0;
		private var _cols:int = 0;
		private var _diag:Boolean;
		private var _heur:Function;
		
		public function AiNodeGrid(rowCount:int, colCount:int, diag:Boolean=true, heur:Function=null )
		{
			_grid = new Array(rowCount * colCount);
			_rows = rowCount;
			_cols = colCount;
			_diag = diag;
			_heur = (heur is Function) ? heur : Heuristics.distEuclidianSquared;
		}
		
		public function get rows():int { return _rows; }
		public function set rows(value:int):void
		{
			_rows = value;
			var len:int = _rows * _cols;
			var arr:Array = new Array(len);
			
			for (var i:int = 0; i < len; i++)
			{
				var row:int = Math.floor(i / _cols);
				var col:int = i % _cols;
				
				arr[i] = this.getNode( row, col );
			}
			
			_grid = arr;
		}
		
		public function get columns():int { return _cols; }
		public function set columns(value:int):void
		{
			_cols = value;
			var len:int = _rows * _cols;
			var arr:Array = new Array(len);
			
			for (var i:int = 0; i < len; i++)
			{
				var row:int = Math.floor(i / _cols);
				var col:int = i % _cols;
				
				arr[i] = this.getNode( row, col );
			}
			
			_grid = arr;
		}
		
		public function get area():int { return _rows * _cols; }
		
		public function get diagonalNeighbours():Boolean { return _diag; }
		public function set diagonalNeighbours(value:Boolean):void { _diag = value; }
		
		public function get heuristicFunction():Function { return _heur; }
		public function set heuristicFunction(value:Function):void { if(value is Function) _heur = value; }
		
	/**
	 * IAiNodePool Interface
	 */
		public function get numMembers():int { return _grid.length; }
		
		public function get members():Array { return _grid.slice(); }
/**
 * Methods
 */
		public function getNode( row:int, col:int ):IAiNode
		{
			if(row >= _rows || row < 0) return null;
			if(col >= _cols || col < 0) return null;
			
			return _grid[ computeIndex(row,col) ]; 
		}
		
		public function setNode( node:IAiNode, row:int, col:int ):void
		{
			if(row >= _rows || row < 0) throw new Error("com.lordofduct.engines.ai::AiNodeGrid - coordinates must be with in the area of the grid.");
			if(col >= _cols || col < 0) throw new Error("com.lordofduct.engines.ai::AiNodeGrid - coordinates must be with in the area of the grid.");
			
			_grid[ computeIndex(row,col) ] = node;
		}
		
		public function getCoordFor( node ):Point
		{
			var index:int = _grid.indexOf( node );
			
			if (index < 0) return null;
			
			var row:int = Math.floor( index / _cols );
			var col:int = index % _cols;
			
			return new Point( row, col );
		}
		
		private function computeIndex( row:int, col:int ):int
		{
			return row * _cols + col;
		}
	/**
	 * IAiPool Interface
	 */
		public function contains(node:IAiNode):Boolean
		{
			return _grid.indexOf(node) >= 0;
		}
		
		public function containsSeveral(...args):Boolean
		{
			for each( var node:IAiNode in args )
			{
				if(_grid.indexOf(node) < 0) return false;
			}
			
			return true;
		}
		
		public function getNeighbours(node:IAiNode):Array
		{
			var index:int = _grid.indexOf( node );
			
			if(index < 0) return null;
			
			var neigh:Array = new Array();
			var row:int = Math.floor( index / _cols );
			var col:int = index % _cols;
			var node:IAiNode;
			
			//N
			node = this.getNode( row - 1, col );
			if(node) neigh.push(node);
			//E
			node = this.getNode( row, col + 1 );
			if(node) neigh.push(node);
			//S
			node = this.getNode( row + 1, col );
			if(node) neigh.push(node);
			//W
			node = this.getNode( row, col - 1 );
			if(node) neigh.push(node);
			
			if(_diag)
			{
				//NE ---
				node = this.getNode( row - 1, col + 1 );
				if(node) neigh.push(node);
				//SE ---
				node = this.getNode( row + 1, col + 1 );
				if(node) neigh.push(node);
				//SW ---
				node = this.getNode( row + 1, col - 1 );
				if(node) neigh.push(node);
				//NW ---
				node = this.getNode( row - 1, col - 1 );
				if(node) neigh.push(node);
			}
			
			return neigh;
		}
		
		public function heuristicDistance(node1:IAiNode, node2:IAiNode):Number
		{
			var i1:int = _grid.indexOf( node1 );
			var i2:int = _grid.indexOf( node2 );
			
			if(i1 < 0 || i2 < 0) return Number.POSITIVE_INFINITY;
			
			return _heur( Math.floor( i1 / _cols ), (i1 % _cols), Math.floor( i2 / _cols ), (i2 % _cols) );
		}
		
	/**
	 * IClonable Interface
	 */
		public function clone():*
		{
			var pool:AiNodeGrid = new AiNodeGrid( this.rows, this.columns, this.diagonalNeighbours, this.heuristicFunction );
			
			var len:int = _grid.length;
			
			for( var i:int = 0; i < len; i++ )
			{
				var row:int = Math.floor( i / _cols );
				var col:int = i % _cols;
				
				pool.setNode( _grid[i], row, col );
			}
			
			return pool;
		}
		
		public function copy(obj:*):void
		{
			var pool:AiNodeGrid = obj as AiNodeGrid;
			
			if(!pool) return;
			
			_rows = pool.rows;
			_cols = pool.columns;
			_grid = pool.members;
			_diag = pool.diagonalNeighbours;
			_heur = pool.heuristicFunction;
		}
	}
}