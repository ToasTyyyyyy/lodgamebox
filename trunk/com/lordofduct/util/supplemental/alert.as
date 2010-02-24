/**
 * METHOD
 * 
 * alert - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * 
 * Set an alert out to javascript... if not available trace out the str
 * 
 * DEPRICATED
 */
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