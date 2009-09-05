/**
 * URIPlaylist - by Dylan Engelman a.k.a. Lordofduct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This is a relational list of strings representing media in a playlist. 
 * Its purpose is to contain a series of uri's to media on the internet 
 * that can be streamed. Several gigo.media object's utilize the URIPlaylist 
 * as a factory component in constructing different lists.
 * 
 * Each media item will be represented by a combo set of:
 * 
 * item.@prop - id - a string representing a unique name given to the media
 * item.@prop - uri - a string representing the location and name of the media
 * item.@prop - props - an object that can be used to store some unique information about the media
 * item.@prop - context - some type of LoaderContext used for the media item if any.
 * 
 * Special objects that use this may define special "props" to be used for things like a LoaderContext object.
 */
package com.lordofduct.media
{
	import com.lordofduct.util.IIdentifiable;
	
	import flash.utils.Dictionary;
	import flash.utils.Proxy;

	final public class URIPlaylist extends Proxy implements IIdentifiable
	{
		private var _id:String;
		private var _idToItems:Dictionary = new Dictionary();
		private var _items:Array = new Array();
		
		public function URIPlaylist(idx:String)
		{
			super();
			
			_id = idx;
		}
		
		public function get id():String { return _id; }
		public function set id(value:String):void { _id = value; }
		
		public function addMember( idx:String, uri:String, props:Object=null, cont:*=null ):void
		{
			var item:URIPlItem = new URIPlItem(idx,uri,props,cont);
			_idToItems[idx] = item;
			_items.push( item );
		}
		
		public function deleteMember( idx:String ):void
		{
			var item:URIPlItem = _idToItems[idx];
			delete _idToItems[idx];
			if (item && _items.indexOf( item ) >= 0) _items.splice( _items.indexOf( item ), 1 );
		}
		
		public function deleteAll():void
		{
			_idToItems = new Dictionary();
			_items = new Array();
		}
		
		public function getMember( idx:String ):URIPlItem
		{
			return _idToItems[ idx ];
		}
		
		public function toArray():Array
		{
			return _items.concat();
		}
		
		public function applyReorderList( arr:Array ):void
		{
			this.deleteAll();
			for (var i:int = 0; i < arr.length; i++)
			{
				this.addMember( arr[i].id, arr[i].uri, arr[i].props, arr[i].context );
			}
		}
		
		
/**
 * Proxy overrides
 */
		flash_proxy override function callProperty(methodName:*, ...args):*
		{
			trace("gigo.media::URIPlaylist - Method {"+methodName+"} not found.");
			return null;
		}
		
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			var item:URIPlItem = _idToItems[name];
			var bool:Boolean = delete _idToItems[name];
			if (item && _items.indexOf( item ) >= 0) _items.splice( _items.indexOf( item ), 1 );
			return bool;
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			return _idToItems[name];
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			return Boolean( _idToItems[name] );
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			trace("gigo.media::URIPlaylist - Property {" + name + "} can not be set, create properties using the factory methods supplied.");
		}
		
		flash_proxy override function nextName(index:int):String
		{
			return (_items[index - 1]) ? _items[index - 1].id : null;
		}
		
		flash_proxy override function nextNameIndex(index:int):int
		{
			return (index < _items.length) ? index + 1 : 0;
		}
		
		flash_proxy override function nextValue(index:int):*
		{
			return _items[index - 1];
		}
	}
}

/**
 * local class to URIPlaylist - this is merely there to describe the interface of members of URIPlaylist
 * 
 * The class is dynamic and returned as an Object. When passing in a new reorderList you can use your own 
 * custom Object. They Object must have the props outlined in this class.
 * 
 * Basically implementation through composition
 */
dynamic class URIPlItem extends Object
{
	public var id:String;
	public var uri:String;
	public var props:Object;
	public var context:Boolean;
	
	public function URIPlItem( idx:String, urix:String, propsx:Object=null, cont:*=null)
	{
		id = idx;
		uri = urix;
		props = (propsx) ? propsx : null;
		context = (cont) ? cont : null;
	}
}