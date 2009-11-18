package com.lordofduct.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class AssetParcel extends EventDispatcher
	{
		private var _id:String;
		
		private var _cued:Array;
		private var _loading:Array;
		private var _completed:Array;
		
		public function AssetParcel( idx:String )
		{
			_id = idx;
			
			super();
			
			_cued = new Array();
			_loading = new Array();
			_completed = new Array();
		}
		
		public function get id():String { return _id; }
		
		public function addResourceToCue( idx:String, srcString:String, forceFileType:String=null ):void
		{
			var asset:Asset = new Asset( idx, srcString, forceFileType );
			_cued.push( asset );
		}
		
		public function loadCue():void
		{
			while(_cued.length)
			{
				var asset:Asset = _cued.pop() as Asset;
				if(!asset) continue;
				
				asset.addEventListener( Event.COMPLETE, onAssetLoaded, false, 0, true );
				_loading.push(asset);
				asset.load();
			}
		}
		
		public function getCompletedAssets():Array
		{
			return _completed.slice();
		}
		
		public function dumpCued():void
		{
			_cued.length = 0;
		}
		
		public function dumpCompleted():void
		{
			_completed.length = 0;
		}
		
		public function dumpLoading():void
		{
			while( _loading.length )
			{
				var asset:Asset = _loading.pop() as Asset;
				if(!asset) continue;
				
				asset.removeEventListener( Event.COMPLETE, onAssetLoaded );
				//asset.close()
			}
		}
		
	/**
	 * Event Listeners
	 */
		private function onAssetLoaded(e:Event):void
		{
			//get asset
			var asset:Asset = e.currentTarget as Asset;
			if(!asset) return;
			
			//clean the asset
			asset.removeEventListener( Event.COMPLETE, onAssetLoaded );
			var index:int = _loading.indexOf( asset );
			if(index >= 0) _loading.splice(index, 1);
			
			//push asset into completed
			_completed.push(asset);
			
			//finally if the loading cue is empty, we're done
			if(!_loading.length)
			{
				this.dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
	}
}