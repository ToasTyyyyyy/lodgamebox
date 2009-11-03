/**
 * NOT FUNCTIONING PROPERLY
 */

package com.lordofduct.util
{
	import flash.utils.Dictionary;
	
	public class PoolingManager
	{
		private static var _inst:PoolingManager;
		
		public static function get instance():PoolingManager
		{
			if (!_inst) _inst = SingletonEnforcer.gi(PoolingManager);
			
			return _inst;
		}
		
		public function PoolingManager()
		{
			SingletonEnforcer.assertSingle(PoolingManager);
		}
/**
 * Class Definition
 */
		private var _pools:Dictionary = new Dictionary();
		private var _usePool:Boolean = false;
		
		public function clone( obj:IClonable ):IClonable
		{
			if(_usePool)
			{
				return obj.clone();
			} else
			{
				return obj.clone();
			}
		}
	}
}