package com.lordofduct.net.workers
{
	import com.lordofduct.net.Asset;
	import com.lordofduct.net.AssetFileTypes;
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.IDisposable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class Worker extends EventDispatcher implements IDisposable
	{
		private var __loader:*;
		
		private var _asset:Asset;
		private var _bytesLoaded:int = -1;
		private var _bytesTotal:int = -1;
		
		public function Worker( asset:Asset )
		{
			Assertions.notNil( asset, "com.lordofduct.net.workers::Worker - param asset must be non-null." );
			_asset = asset;
		}
		
		public function get bytesLoaded():int { return _bytesLoaded; }
		
		public function get bytesTotal():int { return _bytesTotal; }
		
		public function get relatedAsset():Asset { return _asset; }
		
		public function get visibleType():Boolean { return false; }
		
		protected function get loader():* { return __loader; }
		protected function set loader(value:*):void { __loader = value; }
/**
 * Methods
 */
		public function cloneAssetContent():Object
		{
			return null;
			//override this bitch
		}
		
		public function close():void
		{
			//overrise this bitch
		}
		
		public function load( req:URLRequest=null, context:*=null ):void
		{
			//overrise this bitch
		}
		
		protected function removeRelevantEventListeners():void
		{
			if(__loader)
			{
				__loader.removeEventListener(Event.OPEN, onOpen);
				__loader.removeEventListener(Event.COMPLETE, onComplete);
				__loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				__loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				__loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOLoadError);
				__loader.removeEventListener(IOErrorEvent.DISK_ERROR, onIOLoadError);
				__loader.removeEventListener(IOErrorEvent.NETWORK_ERROR, onIOLoadError);
				__loader.removeEventListener(IOErrorEvent.VERIFY_ERROR, onIOLoadError);
				__loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
		}
		
	/**
	 * Event Listeners
	 */
		protected function onOpen(e:Event):void
		{
			if(_asset) _asset.dispatchEvent( e.clone() );
		}
		
		protected function onProgress(e:ProgressEvent):void
		{
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
			
			if(_asset) _asset.dispatchEvent( e.clone() );
		}
		
		protected function onHTTPStatus(e:HTTPStatusEvent):void
		{
			if(hse.status != 0 && hse.status != 200)
			{
				this.removeRelevantEventListeners();
				this.close();
			}
			
			if(_asset) _asset.dispatchEvent( e.clone() );
		}
		
		protected function onIOLoadError(e:IOErrorEvent):void
		{
			this.removeRelevantEventListeners();
			if(_asset) _asset.dispatchEvent( e.clone() );
		}
		
		protected function onSecurityError(e:SecurityErrorEvent):void
		{
			this.removeRelevantEventListeners();
			if(_asset) _asset.dispatchEvent( e.clone() );
		}
		
		protected function onComplete(e:Event):void
		{
			this.removeRelevantEventListeners();
			if(_asset) _asset.dispatchEvent( e.clone() );
		}
		
	/**
	 * IDisposable Interface
	 */
		public function dispose():void
		{
			this.close();
			
			__loader = null;
			_asset = null;
		}
		
		public function reengage(...args):void
		{
			this.dispose();
		}
		
		
		
/**
 * Static Interface
 */
		static private var _filetypeClazzes:Dictionary = buildDefaultFiletypes();
		
		static private function buildDefaultFiletypes():Dictionary
		{
			var dict:Dictionary = new Dictionary();
			
			dict[AssetFileTypes.JPG ] = BitmapWorker;
			dict[AssetFileTypes.JPEG] = BitmapWorker;
			dict[AssetFileTypes.PNG ] = BitmapWorker;
			dict[AssetFileTypes.GIF ] = BitmapWorker;
			dict[AssetFileTypes.BMP ] = BitmapWorker;
			dict[AssetFileTypes.SWF ] = SWFWorker;
			dict[AssetFileTypes.XML ] = XMLWorker;
			dict[AssetFileTypes.MP3 ] = SoundWorker;
			dict[AssetFileTypes.AIF ] = SoundWorker;
			dict[AssetFileTypes.CSS ] = SylteSheetWorker;
			
			dict[AssetFileTypes.LOCAL ] = LocalWorker;
			
			return dict;
		}
		
		static public function registerWorkerForFileType( fileType:String, clazz:Class ):void
		{
			_filetypeClazzes[fileType.toLowerCase()] = clazz;
		}
		
		static public function getWorker( asset:Asset ):Worker
		{
			var clazz:Class = getWorkerClass( asset.fileType );
			return new clazz( asset );
		}
		
		static public function getWorkerClass( fileType:String ):Class
		{
			if(!fileType) return SimpleWorker;
			
			var clazz:Class = _filetypeClazzes[asset.fileType] as Class;
			if(!clazz) clazz = SimpleWorker;
			
			return clazz;
		}
	}
}