/**
 * METHOD
 * 
 * isPrimType - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * 
 * Is the object passed a prim type?
 */
package com.lordofduct.util.supplemental
{
	public function isPrimType( obj:* ):Boolean
	{
		if ( obj == null || obj == undefined ) return true;
		if ( obj is Boolean ) return true;
		if ( obj is String ) return true;
		if ( obj is Number ) return true;
		if ( obj is int ) return true;
		if ( obj is uint ) return true;
		
		return false;
	}
}