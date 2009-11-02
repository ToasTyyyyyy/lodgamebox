package com.lordofduct.net.workers
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import com.lordofduct.net.Asset;
	
	public class SWFWorker extends Worker
	{
		public function SWFWorker(asset:Asset)
		{
			super(asset);
		}
		
		override public function get visibleType():Boolean
		{
			return true;
		}
		
		override public function cloneAssetContent():Object
		{
			var cont:Sprite = this.relatedAsset.content as Sprite;
			
			if(!cont) return null;
			
			var clazz:Class = Object(cont).constructor as Class;
			return new clazz();
		}
		
		override public function close():void
		{
			if(this.loader) this.loader.close();
			
			this.removeRelevantEventListeners();
			this.loader = null;
		}
		
		override public function load( req:URLRequest=null, context:*=null ):void
		{
			if(!this.loader) this.loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.OPEN, super.onOpen,false,0,true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, super.onProgress,false,0,true);
			loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, super.onHTTPStatus,false,0,true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, super.onIOLoadError,false,0,true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.DISK_ERROR, super.onIOLoadError,false,0,true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, super.onIOLoadError,false,0,true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.VERIFY_ERROR, super.onIOLoadError,false,0,true);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, super.onSecurityError,false,0,true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, super.onComplete,false,0,true);
			
			if(req && req.url != this.relatedAsset.source) throw new Error("com.lordofduct.net::Worker - when loading an Worker and supplying a URLRequest, both sources must match");
			else req = new URLRequest( this.relatedAsset.source );
			Loader(this.loader).load( req, context as LoaderContext );
		}
		
		override protected function onComplete(e:Event):void
		{
			var swf:Sprite = this.loader.content as Sprite;
			this.relatedAsset.applyAssetData( swf, this.relatedAsset.fileType, this.relatedAsset.source );
			
			super.onComplete(e);
		}
	}
}