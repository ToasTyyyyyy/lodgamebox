/**
 * XMLLoader - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * Copyright (c) 2009 Dylan Engelman
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, 
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject to the following 
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies 
 * or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * 
 * In other words, no guarantees are made that it will work as expected nor that I (Dylan Engelman) 
 * have to repair or give any assistance to you the user when you have troubles.
 * 
 * 
 * This is a special class for loading XML. Now the difference between loading XML with a URLLoader and this 
 * really isn't much different. What extra capabilities this adds is to the users discression if they want to use it.
 * 
 * Firstly, the XMLLoader ONLY loads XML and hands out the data typed as XML. You can not set the dataFormat or any properties 
 * for that matter. It takes care of it all.
 * 
 * Next it adds the capability for remotely linked XML nodes. What this means is that a given XML file can be broken into several .xml 
 * files and linked together as sub nodes easily. You utilize the 'lodxml' namespace to do this. All src references must be relative to the 
 * root XML document that is used to start the load process, or as fully qualified uris. (./... vs http://somedomain.com/...).
 * 
 * To make use of this feature you first most declare the 'lodxml' for every .xml document that will have remote xml files. Then each 
 * node that relates to a remote xml file must be named in the 'lodxml' namespace as the name 'remotexml' and have a src attached to it.
 * 
 * example:
 * 
 * mainXml.xml
 * 
 * <root xmlns:lodxml="lodxml" >
 * 		<node name="a" />
 * 		<lodxml:remotexml src="./subXml.xml" />
 * 		<node name="c" />
 * </root>
 * 
 * subXml.xml
 * 
 * <node name="b">
 * 		<sub>Foo</sub>
 * 		<sub>Bar</sub>
 * 		<sub>Hello World!</sub>
 * </node>
 * 
 * 
 * Once loaded will result in:
 * 
 * <root xmlns:lodxml="lodxml" >
 * 		<node name="a" />
 * 		<node name="b">
 * 			<sub>Foo</sub>
 * 			<sub>Bar</sub>
 * 			<sub>Hello World!</sub>
 * 		</node>
 * 		<node name="c" />
 * </root>
 * 
 * 
 * 
 * This is extremely useful if you have tons of xml in one document that is cumbersome to write. Or if you have changing xml on a sub level.
 * 
 * For instance say you were designing a video game that had several "game matches". These "game matches" have corresponding XML for them that can be swapped out. 
 * The assets for which are stored in sub directories of the root directory. You can define the level's config xml in each sub directory, and then have a super xml 
 * that references all the config xml files for each level. If you want to remove a level from the game you just remove the remotexml link from the super xml document 
 * and just leave the levels assets and configuration alone in the sub directory. This way you can have multiple configurations for a game with out having to write 
 * long winded xml configurations for each and every level.
 * 
 * This can get even more dynamic when you bring PHP and the sort into the match.
 * 
 * 
 * NOTE - lodxml:remotexml nodes can NOT have complex data in them. They are ignored if they do. The node being replaced must be simple so that it can be replaced.
 * 
 * NOTE - the bytesLoaded and bytesTotal values may not accurately represent the size of the XML when there are remote nodes. Because each remote node is loaded independently 
 * and the loader doesn't know the size of them until they start loading, the bytesTotal size will increase as more nodes are added to the que. If you are watching these values 
 * to update some preloader bar, this may cause the preloader to jump upto near 100% and then back down again over and over as new remotexml nodes are added into the que.
 * 
 * NOTE - you can turn off a remotexml node to keep it from loading by setting an attribute of 'active' to false.
 * 
 * ex: <lodxml:remotexml src="./someXml.xml" active="false" />
 */
package com.lordofduct.net
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.IDisposable;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class XMLLoader extends EventDispatcher implements IDisposable
	{
		private var _loader:URLLoader;
		private var _xmlData:XML;
		private var _bytesLoaded:int = 0;
		private var _bytesTotal:int = 0;
		
		private var _openSubLoaders:Array;
		private var _closedSubLoaders:Array;
		private var _subloadersToSrcUri:Dictionary;
		
		public function XMLLoader( req:URLRequest=null )
		{	
			super();
			
			if(req) this.load(req);
		}
		
		public function get bytesLoaded():int { return _bytesLoaded; }
		
		public function get bytesTotal():int { return _bytesTotal; }
		
		public function get data():XML { return _xmlData; }
		
		public function get dataFormat():String { return "text"; }
		
/**
 * Methods
 */
		public function close():void
		{
			if(_loader)
			{
				_loader.close();
				
				_loader.removeEventListener( Event.COMPLETE, this.onLoadComplete );
				_loader.removeEventListener( ProgressEvent.PROGRESS, this.onProgress );
				
				_loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent );
				_loader.removeEventListener( IOErrorEvent.IO_ERROR, this.dispatchEvent );
				_loader.removeEventListener( Event.OPEN, this.dispatchEvent );
				_loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent );
				_loader.removeEventListener( "httpResponseStatus", this.dispatchEvent );
				_loader = null;
			}
			
			var subloader:XMLLoader;
			
			for each( subloader in _openSubLoaders )
			{
				subloader.close();
				
				subloader.removeEventListener( Event.COMPLETE, this.onSubLoadComplete );
				subloader.removeEventListener( ProgressEvent.PROGRESS, this.onProgress );
				
				subloader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent );
				subloader.removeEventListener( IOErrorEvent.IO_ERROR, this.dispatchEvent );
				subloader.removeEventListener( Event.OPEN, this.dispatchEvent );
				subloader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent );
				subloader.removeEventListener( "httpResponseStatus", this.dispatchEvent );
			}
			
			for each( subloader in _closedSubLoaders )
			{
				subloader.close();
				
				subloader.removeEventListener( Event.COMPLETE, this.onSubLoadComplete );
				subloader.removeEventListener( ProgressEvent.PROGRESS, this.onProgress );
				
				subloader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent );
				subloader.removeEventListener( IOErrorEvent.IO_ERROR, this.dispatchEvent );
				subloader.removeEventListener( Event.OPEN, this.dispatchEvent );
				subloader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent );
				subloader.removeEventListener( "httpResponseStatus", this.dispatchEvent );
			}
			
			_openSubLoaders = null;
			_closedSubLoaders = null;
			_subloadersToSrcUri = null;
		}
		
		public function load(req:URLRequest):void
		{
			Assertions.nil( _loader, "com.lordofduct.net::XMLLoader - can not load anything when XMLLoader is already loading." );
			
			_loader = new URLLoader();
			_loader.dataFormat = "text";
			_loader.addEventListener( Event.COMPLETE, this.onLoadComplete, false, 0, true );
			_loader.addEventListener( ProgressEvent.PROGRESS, this.onProgress, false, 0, true );
			
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent, false, 0, true );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, this.dispatchEvent, false, 0, true );
			_loader.addEventListener( Event.OPEN, this.dispatchEvent, false, 0, true );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent, false, 0, true );
			_loader.addEventListener( "httpResponseStatus", this.dispatchEvent, false, 0, true );
			
			_loader.load( req );
		}
		
		public function parseXMLText( txt:* ):void
		{
			_xmlData = new XML( txt );
			
			if(_xmlData.namespace("lodxml"))
			{
				var list:XMLList = _xmlData.descendants( new QName("lodxml", "remotexml") ).(hasOwnProperty("@src") && !hasComplexContent() && !(hasOwnProperty("@active") && @active.toLowerCase() == "false"));
				var len:int = list.length();
				if(!len)
				{
					this.dispatchEvent( new Event( Event.COMPLETE ) );
					this.close();
					return;
				}
				
				_openSubLoaders = new Array();
				_closedSubLoaders = new Array();
				_subloadersToSrcUri = new Dictionary();
				var closed:Array = new Array();
				
				for( var i:int = 0; i < len; i++ )
				{
					var src:String = list[i].@src;
					if(closed.indexOf(src) >= 0) continue;
					
					var subloader:XMLLoader = new XMLLoader();
					subloader.addEventListener( Event.COMPLETE, this.onSubLoadComplete, false, 0, true );
					subloader.addEventListener( ProgressEvent.PROGRESS, this.onProgress, false, 0, true );
					
					subloader.addEventListener( HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent, false, 0, true );
					subloader.addEventListener( IOErrorEvent.IO_ERROR, this.dispatchEvent, false, 0, true );
					subloader.addEventListener( Event.OPEN, this.dispatchEvent, false, 0, true );
					subloader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent, false, 0, true );
					subloader.addEventListener( "httpResponseStatus", this.dispatchEvent, false, 0, true );
					subloader.load( new URLRequest( src ) );
					
					_openSubLoaders.push(subloader);
					_subloadersToSrcUri[subloader] = src;
				}
			} else {
				this.close();
				this.dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		private function onLoadComplete(e:Event):void
		{
			this.parseXMLText( _loader.data );
		}
		
		private function onSubLoadComplete(e:Event):void
		{
			if(!_subloadersToSrcUri || !_openSubLoaders) return;
			
			var subloader:XMLLoader = e.currentTarget as XMLLoader;
			if(!subloader) return;
			
			subloader.removeEventListener( Event.COMPLETE, this.onSubLoadComplete );
			subloader.removeEventListener( ProgressEvent.PROGRESS, this.onProgress );
			
			subloader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, this.dispatchEvent );
			subloader.removeEventListener( IOErrorEvent.IO_ERROR, this.dispatchEvent );
			subloader.removeEventListener( Event.OPEN, this.dispatchEvent );
			subloader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.dispatchEvent );
			subloader.removeEventListener( "httpResponseStatus", this.dispatchEvent );
			
			var src:String = _subloadersToSrcUri[subloader];
			var xml:XML = subloader.data;
			
			var list:XMLList = _xmlData.descendants( new QName("lodxml", "remotexml") ).(hasOwnProperty("@src") && @src == src && !hasComplexContent() && !(hasOwnProperty("@active") && @active.toLowerCase() == "false") );
			
			for each( var node:XML in list )
			{
				node.parent().replace( node.childIndex(), xml );
			}
			
			var index:int = _openSubLoaders.indexOf(subloader);
			if(index >= 0) _openSubLoaders.splice( index, 1 );
			_closedSubLoaders.push( subloader );
			delete _subloadersToSrcUri[subloader];
			
			if(!_openSubLoaders.length)
			{
				this.close();
				this.dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			var bl:int = (_loader) ? _loader.bytesLoaded : 0;
			var bt:int = (_loader) ? _loader.bytesTotal : 0;
			
			var subloader:XMLLoader;
			
			for each( subloader in _openSubLoaders )
			{
				bl += subloader.bytesLoaded;
				bt += subloader.bytesTotal;
			}
			
			for each( subloader in _closedSubLoaders )
			{
				bl += subloader.bytesLoaded;
				bt += subloader.bytesTotal;
			}
			
			_bytesLoaded = bl;
			_bytesTotal = bt;
			
			if(e.currentTarget == _loader || _openSubLoaders.indexOf(e.currentTarget) == 0)
			{
				this.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal ) );
			}
		}
	/**
	 * IDisposable Interface
	 */
		public function dispose():void
		{
			this.close();
			
			_xmlData = null;
		}
		
		public function reengage(...args):void
		{
			if(args[0])
			{
				this.load(args[0] as URLRequest);
			}
		}
	}
}