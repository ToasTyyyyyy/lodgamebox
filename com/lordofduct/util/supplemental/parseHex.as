package com.lordofduct.util.supplemental
{
	public function parseHex( str:String, radix:uint=2 ):String
	{
		//clamp radix
		if(radix < 2 || radix > 16) throw new Error("parseHex() - radix must be between 2 and 16");
		//strip leading whitespace
		str = str.replace(RegExp("^[ \t]+"), "");
		//check if string is denoted as a hex value
		if(str.indexOf("0x") == 0)
		{
			str = str.slice(2);
			radix = 16;
		}
		//assert regexp for non-numeric values
		var reg:String = "[^0-";
		if(radix < 11) reg += radix.toString();
		else
		{
			reg += "9A-";
			switch(radix)
			{
				case 11: reg += "A"; break;
				case 12: reg += "B"; break;
				case 13: reg += "C"; break;
				case 14: reg += "D"; break;
				case 15: reg += "E"; break;
				case 16: reg += "F"; break;
			}
		}
		reg += "]";
		//clear leading non-numeric values
		str = str.toUpperCase();
		var index:int = str.search(RegExp(reg));
		str = str.slice(0,index);
		//now convert to hex
		//TODO
		
		
		return str;
	}
}