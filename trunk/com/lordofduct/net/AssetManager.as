package com.lordofduct.net
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
		
	public dynamic class AssetManager extends Proxy
	{
		private static var _inst:AssetManager;
		
		public static function get instance():AssetManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(AssetManager);
			
			return _inst;
		}
		
		public function AssetManager()
		{
			SingletonEnforcer.assertSingle(AssetManager);
		}
/**
 * Class Definition
 */
		private var _assets:Dictionary = new Dictionary();
		
		public function addAsset( asset:Asset ):void
		{
			Assertions.notNil( asset, "com.lordofduct.utils::AssetManager - asset param must be non-null" );
			
			_asset[asset.id] = asset;
		}
		
		public function addAssetByObject( idx:String, obj:*, type:String=null, src:String=null, addToContainer:Boolean=true ):void
		{
			Assertions.notNil(idx,"com.lordofduct.utils::AssetManager - idx param must be non-null");
			Assertions.notNil(obj,"com.lordofduct.utils::AssetManager - obj param must be non-null");
			
			var asset:Asset = new Asset( idx );
			asset.applyAssetData( obj, type, src, addToContainer );
			this.addAsset( asset );
		}
		
		public function addRemoteAsset( idx:String, src:String=null, forceFileType:String=null ):void
		{
			this.addAsset( new Asset( idx, src, forceFileType ) );
		}
		
		public function addAndLoadRemoteAsset( idx:String, src:String=null, forceFileType:String=null, req:URLRequest=null, loaderContext:*=null ):void
		{
			var asset:Asset = new Asset( idx, src, forceFileType, req, loaderContext );
			asset.load( req, loaderContext );
			
			this.addAsset( asset );
		}
		
		public function removeAsset( idx:String ):void
		{
			Assertions.notNil(idx,"com.lordofduct.utils::AssetManager - idx param must be non-null");
			delete _assets[idx];
		}
		
		public function removeAll():void
		{
			_assets = new Dictionary();
		}
		
		public function isAvailable( idx:String ):Boolean
		{
			Assertions.notNil(idx,"com.lordofduct.utils::AssetManager - idx param must be non-null");
			return Boolean( _assets[idx] );
		}
		
		public function getAsset( idx:String ):Asset
		{
			Assertions.notNil(idx,"com.lordofduct.utils::AssetManager - idx param must be non-null");
			
			var asset:* = _assets[idx];
			Assertions.notNil(asset,"com.lordofduct.utils::AssetManager - Asset not registered in library with the id: " + idx, Error);
			return asset;
		}
		
		public function getAssetContentClass( idx:String ):Class
		{
			return this.getAsset( idx ).getContentClassType();
		}
		
		public function cloneAssetContent( idx:String ):Object
		{
			return this.getAsset( idx ).cloneContent();
		}
		
/**
 * SWF and SWFLibrary methods
 */
		public function getSWF( idx:String ):Sprite
		{
			var asset:Asset = this.getAsset( idx );
			
			if(!asset) return null;
			
			var spr:Sprite = asset.content as Sprite;
			
			if(!spr || !spr.loaderInfo) return null;
			
			return spr;
		}
		
		public function getClassFromSWFLibrary( idx:String, className:String ):Class
		{
			Assertions.notNil(className, "com.lordofduct.utils::AssetManager - className param must be non-null");
			
			var swf:Sprite = this.getSWF( idx );
			if(!swf) return null;
			
			var clazz:Class = swf.loaderInfo.applicationDomain.getDefinition(className) as Class;
			return clazz;
		}
		
		public function getInstanceFromSWFLibrary( idx:String, className:String ):Object
		{
			var clazz:Class = this.getClassFromSWFLibrary( idx, className );
			return new clazz();
		}
		
/**
 * Proxy overrides
 */
		flash_proxy override function callProperty(methodName:*, ...args):*
		{
			trace("com.lordofduct.utils::AssetManager - Method {"+methodName+"} not found.");
			return null;
		}
		
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			var bool:Boolean = delete _assets[name];
			return bool;
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			return _assets[name];
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			return Boolean( _assets[name] );
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			trace("com.lordofduct.utils::AssetManager - Property {" + name + "} can not be set, create properties using the factory methods supplied.");
		}
	}
}