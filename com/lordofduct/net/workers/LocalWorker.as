package com.lordofduct.net.workers
{
	import com.lordofduct.net.Asset;
	
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.net.URLRequest;

	public class LocalWorker extends Worker
	{
		public function LocalWorker(asset:Asset)
		{
			super(asset);
		}
		
		override public function get visibleType():Boolean
		{
			return this.relatedAsset.content is DisplayObject;
		}
		
		override public function cloneAssetContent():Object
		{
			var obj:Object = this.relatedAsset.content;
			
			if(!obj) return null;
			
			var clazz:Class = Object(obj).constructor as Class;
			return new clazz();
		}
		
		override public function close():void
		{
			//do nothing
		}
		
		override public function load( req:URLRequest=null, context:*=null ):void
		{
			//do nothing
		}
	}
}