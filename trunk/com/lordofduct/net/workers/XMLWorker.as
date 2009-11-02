package com.lordofduct.net.workers
{
	import flash.events.*;
	import flash.net.URLRequest;

	public class XMLWorker extends Worker
	{
		public function XMLWorker(asset:Asset)
		{
			super(asset);
		}
		
		override public function get visibleType():Boolean
		{
			return false;
		}
		
		override public function cloneAssetContent():Object
		{
			if(!this.relatedAsset.content) return null;
			
			return new XML( this.relatedAsset.content );
		}
		
		override public function close():void
		{
			if(this.loader) this.loader.close();
			
			this.removeRelevantEventListeners();
			this.loader = null;
		}
		
		override public function load( req:URLRequest=null, context:*=null ):void
		{
			if(!this.loader) this.loader = new XMLLoader();
			
			this.loader.addEventListener(Event.OPEN, this.onOpen,false,0,true);
			this.loader.addEventListener(ProgressEvent.PROGRESS, this.onProgress,false,0,true);
			this.loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onHTTPStatus,false,0,true);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.onIOLoadError,false,0,true);
			this.loader.addEventListener(IOErrorEvent.DISK_ERROR, this.onIOLoadError,false,0,true);
			this.loader.addEventListener(IOErrorEvent.NETWORK_ERROR, this.onIOLoadError,false,0,true);
			this.loader.addEventListener(IOErrorEvent.VERIFY_ERROR, this.onIOLoadError,false,0,true);
			this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSecurityError,false,0,true);
			this.loader.addEventListener(Event.COMPLETE, this.onComplete,false,0,true);
			
			if(req && req.url != this.relatedAsset.source) throw new Error("com.lordofduct.net::Worker - when loading an Worker and supplying a URLRequest, both sources must match");
			else req = new URLRequest( this.relatedAsset.source );
			XMLLoader( this.loader ).load( req );
		}
		
		override protected function onComplete(e:Event):void
		{
			var data:XML = XML(this.loader.data);
			this.relatedAsset.applyAssetData( data, this.relatedAsset.fileType, this.relatedAsset.source );
			
			super.onComplete(e);
		}
	}
}