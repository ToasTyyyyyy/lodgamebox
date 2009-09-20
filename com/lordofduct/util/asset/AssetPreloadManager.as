package com.lordofduct.util.asset
{
	import com.lordofduct.util.SingletonEnforcer;
	
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