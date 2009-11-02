package com.lordofduct.net
{
	import com.lordofduct.util.IDisposable;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class XMLLoader extends URLLoader implements IDisposable
	{
		private var _xmlData:XML;
		
		public function XMLLoader( request:URLRequest )
		{
			this.addEventListener( Event.COMPLETE, onLoadComplete, false, 0, true );
			
			super(request);
		}
		
		override public function get xmlData():XML { return _xmlData; }
/**
 * Methods
 */
		override public function load(request:URLRequest):void
		{
			this.dataFormat = "text";
			super.load( req );
		}
		
		private function onLoadComplete(e:Event):void
		{
			_xmlData = XML(this.data);
		}
	/**
	 * IDisposable Interface
	 */
		public function dispose():void
		{
			this.close();
		}
		
		public function reengage(...args):void
		{
			if(args[0])
			{
				this.load(args[0] as URLRequest);
			}
		}
	}
}