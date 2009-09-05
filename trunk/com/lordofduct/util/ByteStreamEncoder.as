package com.lordofduct.util
{
	import flash.utils.ByteArray;
	
	public class ByteStreamEncoder
	{
		private var _bitPos:int = 8;
		private var _currentBlock:int = 0;
		private var _blocks:Array = new Array();
		
		public function ByteStreamEncoder()
		{
			
		}
		
/**
 * Methods
 */	
		public function writeBit(data:Boolean):void
	    {
	        this.writeBits(data ? 1 : 0, 1);
	    }
	    
	    public function writeUI( value:uint, size:uint ):void
	    {
	    	Assertions.smallerOrEqual( value, (1<<size) - 1, "com.lordofduct.util::ByteStreamEncoder - bit length is to large", Error );
	    	
	    	writeBits( value, size );
	    }
	    
	    public function writeSI( value:int, size:uint ):void
	    {
	    	Assertions.betweenOrEqual( value, -1<<(size - 1), (1<<size) - 1, "com.lordofduct.util::ByteStreamEncoder - bit length is to large", Error );
	    	
	    	writeBits( uint(value), size );
	    }
	    
	    public function writeUBits( data:int, size:uint ):void
	    {
	    	Assertions.smallerOrEqual( data, (1<<size) - 1, "com.lordofduct.util::ByteStreamEncoder - bit length is to large", Error );
	    	
	    	writeBits( data, size );
	    }
	    
	    public function writeSBits( data:int, size:uint ):void
	    {
	    	Assertions.betweenOrEqual( data, -1<<(size-1), (1<<size) - 1, "com.lordofduct.util::ByteStreamEncoder - bit length is to large", Error );
	    	
	    	writeBits( data, size );
	    }
	    
	    public function writeBits(data:int, size:uint):void
	    {
	        while (size > 0)
	        {
	            if (size > _bitPos)
	            {
	                //if more bits left to write than shift out what will fit
	                _currentBlock |= data << (32 - size) >>> (32 - _bitPos);
	
	                // shift all the way left, then right to right
	                // justify the data to be or'ed in
	                this.write(_currentBlock);
	                size -= _bitPos;
	                _currentBlock = 0;
	                _bitPos = 8;
	            }
	            else // if (size <= bytePos)
	            {
	                _currentBlock |= data << (32 - size) >>> (32 - _bitPos);
	                _bitPos -= size;
	                size = 0;
	
	                if (_bitPos == 0)
	                {
	                    //if current byte is filled
	                    this.write(_currentBlock);
	                    _currentBlock = 0;
	                    _bitPos = 8;
	                }
	            }
	        }
	    }
	    
	    public function writeToByteArray( bar:ByteArray=null ):ByteArray
	    {
	    	if(!bar) bar = new ByteArray();
	    	
	    	for (var i:int = 0; i < _blocks.length; i++)
	    	{
	    		bar.writeByte(_blocks[i]);
	    	}
	    	
	    	bar.writeByte(_currentBlock);
	    	
	    	return bar;
	    }
	    
	    private function write( block:int ):void
	    {
	    	Assertions.smaller( block, 0x100, "com.lordofduct.util::ByteStreamEncoder - byte write error", Error );
	    	_blocks.push(block);
	    }
	    
/**
 * Static Interface
 */
		public static function maxNum(...args):int
		{
			for (var i:int = 0; i < args.length; i++)
			{
				args[i] = Math.abs(args[i]);
			}
			
			return Math.max.apply(null, args);
			/* 
			//take the absolute values of the given numbers
			a = Math.abs(a);
			b = Math.abs(b);
			c = Math.abs(c);
			d = Math.abs(d);
			
			//compare the numbers and return the unsigned value of the one with the greatest magnitude
			return a > b
			        ? (a > c
			            ? (a > d ? a : d)
			            : (c > d ? c : d))
			        : (b > c
			            ? (b > d ? b : d)
			            : (c > d ? c : d)); */
		}
		
		public static function minBits(number:int, bits:int):int
		{
			var val:int = 1;
			for (var x:int = 1; val <= number && !(bits > 32); x <<= 1) 
			{
				val = val | x;
				bits++;
			}
			
			if (bits > 32)
			{
				trace("minBits " + bits + " must not exceed 32");
			}
			return bits;
		}
	}
}