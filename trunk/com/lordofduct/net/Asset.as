package com.lordofduct.net
{
	import com.lordofduct.net.workers.Worker;
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.IIdentifiable;
	import com.lordofduct.util.StringUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	public class Asset extends EventDispatcher implements IIdentifiable
	{
		private var _id:String;
		
		private var _data:Object;
		private var _src:String;
		private var _fileType:String;
		
		private var _visible:Boolean = false;
		private var _cont:Sprite;
		
		private var _worker:Worker;
		
		public function Asset( idx:String, src:String=null, forceFileType:String=null )
		{	
			Assertions.isNotTrue( !idx && !src, "com.lordofduct.net::Asset - either the param idx OR src must be present to create a libraryName for this Asset." );
			
			_id = idx;
			
			if(!_id)
			{
				trace("WARNING: No id was supplied for asset with source {"+source+"} using the source as the id");
				_id = src;
			}
			
			this.setSource( src, forceFileType );
		}
		
		public function get id():String { return _id; }
		public function set id(value:String):void { }
		
		public function get content():Object { return _data; }
		
		public function get fileType():String { return _fileType; }
		
		public function get source():String { return _src; }
		
		public function get visible():Boolean { return _visible; }
		
		public function get visibleContainer():Sprite { return _cont; }
		
		public function get worker():Worker { return _worker; }
/**
 * Methods
 */
		public function applyAssetData( data:Object, type:String, src:String=null, addToContainer:Boolean=true ):void
		{
			if(!type) type = AssetFileTypes.LOCAL;
			
			_data = data;
			_fileType = type;
			_src = src;
			
			this.updateWorker();
			this.checkVisibility();
			
			var obj:DisplayObject = this.content as DisplayObject;
			if(this.visible && this.visibleContainer && obj && addToContainer)
			{
				this.visibleContainer.addChild(obj);
			}
		}
		
		public function cloneContent():Object
		{
			return (_worker) ? _worker.cloneAssetContent() : null;
		}
		
		public function getContentClassType():Class
		{
			return (_data) ? Object(_data).constructor as Class : null;
		}
		
		public function load(req:URLRequest=null, loaderContext:*=null):void
		{
			Assertions.notNil( _src, "com.lordofduct.net::Asset - can not load if source is not set. Please run 'setSource(...)' before loading.", Error );
			
			this.updateWorker();
			this.checkVisibility();
			
			if(req) Assertions.equal( req.url, _src, "com.lordofduct.net::Asset - when loading an Asset and supplying a URLRequest, both sources must match" );
			else req = new URLRequest( _src );
			
			_worker.load( req, loaderContext );
		}
		
		public function setSource( src:String, forceFileType:String=null ):void
		{
			//set source uri
			_src = src;
			
			//set filetype
			if(!forceFileType)
			{
				var type:String = StringUtils.findFileType( _src );
				Assertions.notNil( type, "com.lordofduct.net::Asset - the fileType could not be found for this source uri.", Error );
				_fileType = type;
			} else {
				_fileType = forceFileType.toLowerCase();
			}
		}
		
	/**
	 * Private Interface
	 */
		private function checkVisibility():void
		{
			_visible = (_worker) ? _worker.visibleType : false;
			
			if(_visible && !_cont) _cont = new Sprite();
			else _cont = null;
		}
		
		private function updateWorker():void
		{
			var work:Worker = Worker.getWorker( this );
			var workerClazz:Class = Object(work).constructor as Class;
			
			if(!_worker || !(_worker is workerClazz) ) _worker = work;
		}
	}
}