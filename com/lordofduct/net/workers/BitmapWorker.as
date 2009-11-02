package com.lordofduct.net.workers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import com.lordofduct.net.Asset;
	
	public class BitmapWorker extends Worker
	{
		public function BitmapWorker(asset:Asset)
		{
			super(asset);
		}
		
		override public function get visibleType():Boolean
		{
			return true;
		}
		
		override public function cloneAssetContent():Object
		{
			var bmp:Bitmap = this.relatedAsset.content as Bitmap;
			
			if(!bmp) return null;
			
			var bmd:BitmapData = bmp.bitmapData;
			return new Bitmap( bmd );
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
			
			this.loader.loaderInfo.addEventListener(Event.OPEN, this.onOpen,false,0,true);
			this.loader.loaderInfo.addEventListener(ProgressEvent.PROGRESS, this.onProgress,false,0,true);
			this.loader.loaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onHTTPStatus,false,0,true);
			this.loader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onIOLoadError,false,0,true);
			this.loader.loaderInfo.addEventListener(IOErrorEvent.DISK_ERROR, this.onIOLoadError,false,0,true);
			this.loader.loaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, this.onIOLoadError,false,0,true);
			this.loader.loaderInfo.addEventListener(IOErrorEvent.VERIFY_ERROR, this.onIOLoadError,false,0,true);
			this.loader.loaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSecurityError,false,0,true);
			this.loader.loaderInfo.addEventListener(Event.COMPLETE, this.onComplete,false,0,true);
			
			if(req && req.url != this.relatedAsset.source) throw new Error("com.lordofduct.net::Worker - when loading an Worker and supplying a URLRequest, both sources must match");
			else req = new URLRequest( this.relatedAsset.source );
			Loader(this.loader).load( req, context as LoaderContext );
		}
		
		override protected function onComplete(e:Event):void
		{
			var bmp:Bitmap = this.loader.content as Bitmap;
			this.relatedAsset.applyAssetData( bmp, this.relatedAsset.fileType, this.relatedAsset.source );
			
			super.onComplete(e);
		}
	}
}