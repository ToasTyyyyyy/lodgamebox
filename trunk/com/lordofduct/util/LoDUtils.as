package com.lordofduct.util
{
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	//import flash.utils.getTimer;
	
	public class LoDUtils
	{
		public function LoDUtils()
		{
		}
		
		public static function alert( ...args ):void
		{	
			var str:String = args.shift().toString();
			while(args.length) str += " " + args.shift().toString();
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("alert", str );
			} else {
				trace(str);
			}
		}
		
		public static function addEventListenerMultiple( targs:Array, type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference=false ):void
		{
			for each( var obj:IEventDispatcher in targs )
			{
				obj.addEventListener( type, listener, useCapture, priority, useWeakReference );
			}
		}
		
		public static function removeEventListenerMultiple( targs:Array, type:String, listener:Function, useCapture:Boolean=false ):void
		{
			for each( var obj:IEventDispatcher in targs )
			{
				obj.removeEventListener( type, listener, useCapture );
			}
		}
		
		public static function isPrimType( obj:* ):Boolean
		{
			if ( obj == null || obj == undefined ) return true;
			if ( obj is Boolean ) return true;
			if ( obj is String ) return true;
			if ( obj is Number ) return true;
			if ( obj is int ) return true;
			if ( obj is uint ) return true;
			
			return false;
		}
		
		public static function setText( text:String, field:TextField, align:String="left", condenseWhite:Boolean=true, html:Boolean=true ):void
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
		
		/**
		 * Returns the index of the first object with a property <-> value pair passed
		 * 
		 * @param arr:Array - the array to poll
		 * @param prop:String - the property of the object's in the array to check
		 * @param value:* - the value to compare against
		 * @param strict:Boolean - if to use strict equals ===, vs normal equals ==
		 * 
		 * @return int - the index of the object, -1 if no object was found meeting the polling options
		 */
		public static function indexOfOn( arr:Array, prop:String, value:*, strict:Boolean=false ):int
		{
		    var obj:Object;
		
		    for(var i:int = 0; i < arr.length; i++)
		    {
		        obj = arr[i] as Object;
		
		        if(obj && obj.hasOwnProperty(prop))
		        {
		            if(!strict && obj[prop] == value) return i;
		            else if (strict && obj[prop] === value) return i;
		        }
		    }
		
		    return -1;//nothing was found
		}
	}
}