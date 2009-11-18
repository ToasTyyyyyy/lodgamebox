package com.lordofduct.media
{
	internal dynamic class CuePointClasp
	{
		public var alias:String;
		public var position:int;
		public var extras:Object;
		
		public function CuePointClasp( ali:String, pos:int, ext:Object=null )
		{
			this.alias = ali;
			this.position = pos;
			this.extras = ext;
		}

	}
}