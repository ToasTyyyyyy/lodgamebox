/**
 * METHOD
 * 
 * generateHashName - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * 
 * create a hashed name
 */
package com.lordofduct.util.supplemental
{
	import flash.utils.getTimer;
	
	public function generateHashName( prefix:String, salt:int ):String
	{
		var t:int = getTimer();
		var r:int = Math.floor( 0x1000 * Math.random() );
		var high:int = t << 12;
		var low:int = ( r * salt ) % 0x1000;
		t = high + low;
		
		return prefix + "_" + t.toString(16);
	}
}