package com.lordofduct.media
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.SingletonEnforcer;
	
	import flash.display.Loader;
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
		
		public function addAsset( idx:String, obj:* ):void
		{
			Assertions.notNil(idx,"com.lordofduct.utils::AssetManager - idx param must be non-null");
			Assertions.notNil(obj,"com.lordofduct.utils::AssetManager - obj param must be non-null");
			
			_assets[idx] = obj;
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
		
		public function getAsset( idx:String ):*
		{
			Assertions.notNil(idx,"com.lordofduct.utils::AssetManager - idx param must be non-null");
			
			var asset:* = _assets[idx];
			Assertions.notNil(asset,"com.lordofduct.utils::AssetManager - Item not registered in library with the id: " + idx, Error);
			return asset;
		}
		
		public function getAssetClass( idx:String ):Class
		{
			var asset:* = getAsset( idx );
			var clazz:Class = asset.constructor as Class;
			
			Assertions.notNil(clazz,"com.lordofduct.utils::AssetManager - Item with id: " + idx + " does not implicitly derive a Class constructor", Error);
			
			return clazz;
		}
		
		public function cloneAsset( idx:String ):*
		{
			var clazz:Class = getAssetClass(idx);
			return new clazz();
		}
		
/**
 * SWF and SWFLibrary methods
 */
		/**
		 * Returns a loaded SWF object
		 * 
		 * If the SWF is in a Loader instance it returns the content of the Loader, not the Loader itself.
		 */
		public function getSWF( idx:String ):Sprite
		{
			Assertions.notNil(idx,"com.lordofduct.utils::AssetManager - idx param must be non-null");
			
			var asset:Sprite = (_assets[idx] is Loader) ? _assets[idx].content as Sprite : _assets[idx] as Sprite;
			Assertions.notNil(asset, "com.lordofduct.utils::AssetManager - Item not registered in library with the id: " + idx, Error);
			Assertions.notNil(asset.loaderInfo, "com.lordofduct.utils::AssetManager - Item " + idx + " does not contain a LoaderInfo object and must not be a SWF", Error );
			return asset;
		}
		
		public function getClassFromSWFLibrary( idx:String, className:String ):Class
		{
			Assertions.notNil(className, "com.lordofduct.utils::AssetManager - className param must be non-null");
			
			var swf:Sprite = getSWF( idx );
			var clazz:Class = swf.loaderInfo.applicationDomain.getDefinition(className) as Class;
			return clazz;
		}
		
		public function getInstanceFromSWFLibrary( idx:String, className:String ):*
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