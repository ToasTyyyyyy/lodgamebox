package com.lordofduct.geom
{
	import com.lordofduct.util.IClonable;
	
	public class Vector3 extends Point3D
	{
		public function Vector3( i:Number=0, j:Number=0, k:Number=0 )
		{
			super( i, j, k );
		}
		
		override public function clone():*
		{
			return new Vector3( this.x, this.y, this.z );
		}
	}
}