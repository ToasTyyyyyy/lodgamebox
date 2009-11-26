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
	
	public function setText( text:String, field:TextField, align:String="left", condenseWhite:Boolean=true, html:Boolean=true ):void
	{
		field.condenseWhite = condenseWhite;
		
		if(html)
		{
			//fix for img tags in html text... if the first thing in the string is an img tag, 
			//put a blank mark in front of it to allow it to display
			if(text.indexOf( "<img" ) == 0) text = "&nbsp " + text;
			field.htmlText = text;
		}
		else field.text = text;
		
		if (align) field.autoSize = align;
		field.condenseWhite = false;
	}
}