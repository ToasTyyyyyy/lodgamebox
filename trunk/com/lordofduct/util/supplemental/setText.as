/**
 * METHOD
 * 
 * setText - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * 
 * set the text in a textfield
 */
package com.lordofduct.util.supplemental
{
	import flash.text.TextField;
	
	public function setText( text:String, field:TextField, align:String="left", condenseWhite:Boolean=true ):void
	{
		field.condenseWhite = condenseWhite;
		field.htmlText = text;
		if (align) field.autoSize = align;
		field.condenseWhite = false;
	}
}