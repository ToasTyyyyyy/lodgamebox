// ActionScript file
package com.lordofduct.util.supplemental
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	public function simpleClone( obj:Object ):Object
	{
		var clazz:Class = obj.constructor as Class;
		registerClassAlias("lastCloneType", clazz);
		
		var barr:ByteArray = new ByteArray();
		barr.writeObject(obj);
		barr.position = 0;
		return barr.readObject();
	}
}