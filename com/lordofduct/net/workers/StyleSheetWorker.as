package com.lordofduct.net.workers
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	
	import com.lordofduct.net.Asset;
	
	public class StyleSheetWorker extends Worker
	{
		public function StyleSheetWorker(asset:Asset)
		{
			super(asset);
		}
		
		override public function get visibleType():Boolean
		{
			return false;
		}
		
		override public function cloneAssetContent():Object
		{
			var sheet:StyleSheet = this.relatedAsset.content as StyleSheet;
			
			if(!sheet) return null;
			
			var styles:Array = sheet.styleNames;
			var newSheet:StyleSheet = new StyleSheet();
			
			for each( var name:String in styles )
			{
				newSheet.setStyle( name, sheet.getStyle( name ) );
			}
			
			return newSheet;
		}
		
		override public function close():void
		{
			if(this.loader) this.loader.close();
			
			this.removeRelevantEventListeners();
			this.loader = null;
		}
		
		override public function load( req:URLRequest=null, context:*=null ):void
		{
			if(!this.loader) this.loader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, onComplete,false,0,true);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress,false,0,true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.DISK_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.NETWORK_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(IOErrorEvent.VERIFY_ERROR, onIOLoadError,false,0,true);
			loader.addEventListener(Event.OPEN, onOpen,false,0,true);
			
			if(req && req.url != this.relatedAsset.source) throw new Error("com.lordofduct.net::Worker - when loading an Worker and supplying a URLRequest, both sources must match");
			else req = new URLRequest( this.relatedAsset.source );
			URLLoader(this.loader).load( req );
		}
		
		override protected function onComplete(e:Event):void
		{
			var sheet:StyleSheet = new StyleSheet();
			sheet.parseCSS( this.loader.data );
			this.relatedAsset.applyAssetData( sheet, this.relatedAsset.fileType, this.relatedAsset.source );
			
			super.onComplete(e);
		}
	}
}