package com.lordofduct.net
{
	public class AssetFileTypes
	{
		static public const AIF:String = "aif";
		static public const BMP:String = "bmp";
		static public const CSS:String = "css";
		static public const GIF:String = "gif";
		static public const JPG:String = "jpg";
		static public const JPEG:String = "jpeg";
		static public const MP3:String = "mp3";
		static public const PNG:String = "png";
		static public const SWF:String = "swf";
		static public const XML:String = "xml";
		
		public static const LOCAL:String = "_local";
		
		public function AssetFileTypes()
		{
			throw Error("com.lordofduct.net::AssetFileTypes - can not instantiate static member class");
		}
	}
}