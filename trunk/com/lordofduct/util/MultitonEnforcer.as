/**
 * NOT FUNCTIONING PROPERLY
 */

package com.lordofduct.util
{
	import flash.utils.Dictionary;
	
	public class MultitonEnforcer
	{
		public function MultitonEnforcer()
		{
			Assertions.throwError("com.lorofduct.util::MultitonEnforcer - can not instantiate static member class.", Error);
		}
		
/**
 * Static interface
 */
		private static var _insts:Dictionary;
		private static var _typeToQuant:Dictionary;
		
		public static function gi(clazz:Class, index:int=0):*
		{
			var inst:*;
			if(!_insts) _insts = new Dictionary();
			if(!_typeToQuant) _typeToQuant = new Dictionary();
			
			if(!_insts[clazz])
			{
				_insts[clazz] = new Array();
				_typeToQuant[clazz] = -1;
			}
			
			if(_insts[clazz][index] && _insts[clazz][index] != -1) inst=_insts[clazz][index];
			if(!inst)
			{
				inst = new clazz();
				_insts[clazz][index] = inst;
			}
			
			return inst;
		}
		
		public static function setMaxQuantity(clazz:Class, max:int):void
		{
			if(!_insts) _insts = new Dictionary();
			if(!_typeToQuant) _typeToQuant = new Dictionary();
			
			if(!_insts[clazz])
			{
				_insts[clazz] = new Array();
				_typeToQuant[clazz] = -1;
			}
			
			max = Math.max( -1, max );
			_typeToQuant[clazz] = max;
			if(max > -1) _insts[clazz].length = max;
		}
		
		public static function assertMultiton(clazz:Class, inst:*=null, index:int=0 ):void
		{
			var max:int = _typeToQuant[clazz];
			
			if(max >= 0)
			{
				var arr:Array = _insts[clazz];
				arr.length = max;
				
				var i:int = arr.indexOf(undefined);
				if(i < 0) index = arr.indexOf(null);
				
				if( i < 0 ) throw new Error("Error creating class, {"+clazz+"}. You have created the maximum number of this type Multiton that are possible at this time.");
			}
			
			if(inst)
			{
				if ( _insts[index] ) throw new Error("Error creating class, {"+clazz+"}. The Multiton at index '" + index.toString() + "' has already been instantiated.");
				
				_insts[index] = inst;
			}
		}
	}
}