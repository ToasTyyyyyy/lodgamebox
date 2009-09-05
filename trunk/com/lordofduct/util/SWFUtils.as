package com.lordofduct.util
{
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	public class SWFUtils
	{
		public function SWFUtils()
		{
			
		}
		
        public static function writeMatrixToByteStream(m:Matrix, enc:ByteStreamEncoder ):void
        {
			var hasScale:Boolean = m.a != 1 || m.d != 1;
			
			var sX:int = LoDNumberUtils.floatTo1616Fixed(m.a);
			var sY:int = LoDNumberUtils.floatTo1616Fixed(m.d);
			var sBits:int = ByteStreamEncoder.minBits( ByteStreamEncoder.maxNum(sX, sY, 0, 0), 1 );
			
			var hasRotate:Boolean = m.c != 0 || m.b != 0;
			
			var r0:int = LoDNumberUtils.floatTo1616Fixed(m.b);
			var r1:int = LoDNumberUtils.floatTo1616Fixed(m.c);
			var rBits:int = ByteStreamEncoder.minBits( ByteStreamEncoder.maxNum(r0, r1, 0, 0), 1 );
			
			var ix:int = LoDNumberUtils.floatToTwip(m.tx);
			var iy:int = LoDNumberUtils.floatToTwip(m.ty);
			var tBits:int = ByteStreamEncoder.minBits( ByteStreamEncoder.maxNum(ix, iy, 0, 0), 1 );
			
			//write the scale
			enc.writeBit(hasScale);
			if (hasScale)
			{
				enc.writeUBits(sBits, 5);
				enc.writeSI(sX, sBits);
				enc.writeSI(sY, sBits);
			}
			
			//write the rotation
			enc.writeBit(hasRotate);
			if (hasRotate)
			{
				enc.writeUBits(rBits, 5);
				enc.writeSI(r0, rBits);
				enc.writeSI(r1, rBits);
			}
			
			//write translation
			enc.writeUBits(tBits, 5);
			enc.writeSI(ix, tBits);
			enc.writeSI(iy, tBits);
        }
	}
}