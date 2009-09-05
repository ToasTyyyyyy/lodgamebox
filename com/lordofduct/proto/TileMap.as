package com.lordofduct.proto
{
	import com.lordofduct.util.IClonable;
	
	public class TileMap implements IClonable
	{
		private var _map:Array;
		private var _rows:int;
		private var _cols:int;
		
		public function TileMap(rows:uint=1, cols:uint=1, arr:Array=null)
		{
			_rows = rows;
			_cols = cols;
			if(arr) _map = arr.slice();
			else _map = new Array();
		}
		
/**
 * Properties
 */
		public function get numRows():int { return _rows; }
		public function set numRows(value:int):void
		{
			value = Math.max(1, value);
			if(value == _rows) return;
			
			var l:int;
			if(value < _rows)
			{
				l = value * _cols;
				_map.splice(l);
			} else {
				l = value * _cols;
				while(_map.length < l)
				{
					_map.push(null);
				}
			}
			
			_rows = value;
		}
		
		public function get numCols():int { return _cols; }
		public function set numCols(value:int):void
		{
			value = Math.max(1,value);
			if(value == _cols) return;
			
			var i:int;
			
			if(value < _cols)
			{
				var count:int = _cols - value;
				for( i = 0; i < _rows; i++ )
				{
					_map.splice(i * _cols + value, count);
				}
			} else {
				var psh:Array = new Array(value - _cols);
				var tmp:Array;
				i = _rows;
				while(--i)
				{
					tmp = _map.splice(i * _cols + value);
					_map = _map.concat( new Array(count) );
					_map = _map.concat(tmp);
				}
			}
			
			_cols = value;
		}
		
		public function get numTiles():int { return _rows * _cols; }
/**
 * Methods
 */
		public function getTile( col:int, row:int ):*
		{
			if(col >= _cols || row >= _rows) return null;
			
			return _map[ row * _cols + col ];
		}
		
		public function setTile( item:*, col:int, row:int ):void
		{
			if(col >= _cols) this.numCols = col + 1;
			if(row >= _rows) this.numRows = row + 1;
			
			var index:int = row * _cols + col;
			_map[index] = item;
		}
		
		public function concatRow( ...args ):void
		{
			if( args.length > _cols ) this.numCols = args.length;
			
			_map = _map.concat(args);
			_rows++;
		}
		
		public function concatColumn( ...args ):void
		{
			if( args.length > _rows ) this.numRows = args.length;
			
			this.numCols += 1;
			
			for(var i:int = 0; i < args.length; i++)
			{
				this.setTile(args[i], _cols - 1, i);
			}
		}
		
		public function getAsArray():Array
		{
			return _map.slice();
		}
	/**
	 * IClonable Interface
	 */
		public function copy(obj:*):void
		{
			var mp:TileMap = obj as TileMap;
			if(mp)
			{
				_map = mp.getAsArray();
				_rows = mp.numRows;
				_cols = mp.numCols;
			}
		}
		
		public function clone():*
		{
			return new TileMap( _rows, _cols, _map );
		}
	}
}