// ActionScript file
package com.lordofduct.util.supplemental
{
	import flash.external.ExternalInterface;
	
	public function alert( str:String ):void
	{
		if (ExternalInterface.available)
		{
			ExternalInterface.call("alert", str );
		} else {
			trace(str);
		}
	}
}