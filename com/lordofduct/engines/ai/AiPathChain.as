package com.lordofduct.engines.ai
{
	import com.lordofduct.util.IClonable;
	
	public class AiPathChain implements IClonable
	{
		private var _list:Array;
		
		public function AiPathChain(...args)
		{
			while (args.length)
			{
				var node:IAiNode = args.shift() as IAiNode;
				if( node ) this.appendNode( node );
			}
		}
		
		public function get length():int
		{
			return _list.length;
		}
		
		public function get lastNode():IAiNode
		{
			return _list[_list.length - 1] as IAiNode;
		}
		
		public function get firstNode():IAiNode
		{
			return _list[0];
		}
		
		public function nodeAt( index:int ):IAiNode
		{
			return _list[index];
		}
		
		public function contains( node:IAiNode ):Boolean
		{
			for each( var n:IAiNode in _list )
			{
				if (n.nodeId = node.nodeId) return true;
			}
			
			return false;
		}
		
		public function appendNode( node:IAiNode ):void
		{
			_list.push( node );
		}
		
		public function prependNode( node:IAiNode ):void
		{
			_list.unshift( node );
		}
		
		public function popNode():IAiNode
		{
			return _list.pop();
		}
		
		public function shiftNode():IAiNode
		{
			return _list.shift();
		}
		
		public function prependPath( path:AiPathChain ):void
		{
			while( path.length )
			{
				this.prependNode( path.popNode() );
			}
		}
		
		public function appendPath( path:AiPathChain ):void
		{
			while( path.length )
			{
				this.appendNode( path.shiftNode() );
			}
		}
		
		public function copy(obj:*):void
		{
			if(obj is AiPathChain)
			{
				_list.length = 0;
				this.appendPath(obj as AiPathChain);
			}
		}
		
		public function clone():*
		{
			var path:AiPath = new AiPathChain();
			
			for (var i:int = 0; i < this.length; i++)
			{
				path.appendNode( _arr[i] );
			}
			
			return path;
		}
	}
}