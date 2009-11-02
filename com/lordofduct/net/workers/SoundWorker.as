package com.lordofduct.net.workers
{
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	import com.lordofduct.net.Asset;
	
	public class SoundWorker extends Worker
	{
		public function SoundWorker(asset:Asset)
		{
			super(asset);
		}
		
		override public function get visibleType():Boolean
		{
			return false;
		}
		
		override public function cloneAssetContent():Object
		{
			var snd:Sound = this.relatedAsset.content as Sound;
			
			if(!snd) return null;
			
			if(snd.url)
			{
				//if loaded sound load a new one
				return new Sound( new URLRequest( snd.url ) );
			} else {
				//if library sound create a new one
				var clazz:Class = Object(snd).constructor as Class;
				return new clazz();
			}
		}
		
		override public function close():void
		{
			if(this.loader) this.loader.close();
			
			this.removeRelevantEventListeners();
			this.loader = null;
		}
		
		override public function load( req:URLRequest=null, context:*=null ):void
		{
			if(!this.loader) this.loader = new Sound();
			
			loader.addEventListener(Event.COMPLETE, onComplete,false,0,true);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress,false,0,true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.DISK_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.NETWORK_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.VERIFY_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(Event.OPEN, onOpen,false,0,true);
			
			if(req && req.url != this.relatedAsset.source) throw new Error("com.lordofduct.net::Worker - when loading an Worker and supplying a URLRequest, both sources must match");
			else req = new URLRequest( this.relatedAsset.source );
			Sound( this.loader ).load( req, context as SoundLoaderContext );
		}
		
		override protected function onComplete(e:Event):void
		{
			this.relatedAsset.applyAssetData( this.loader, this.relatedAsset.fileType, this.relatedAsset.source );
			
			super.onComplete(e);
		}
	}
}