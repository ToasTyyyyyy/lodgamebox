package com.lordofduct.util
{
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	public class AssetPreloadManager
	{
		private static var _inst:AssetPreloadManager;
		
		public static function get instance():AssetPreloadManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(AssetPreloadManager);
			
			return _inst;
		}
		
		public function AssetManager()
		{
			SingletonEnforcer.assertSingle(AssetPreloadManager);
		}
		
/**
 * Class Definition
 */
	}
}