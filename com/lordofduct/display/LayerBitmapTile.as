package com.lordofduct.display
{
	import com.lordofduct.util.IDisposable;
	import com.lordofduct.util.LoDDisplayObjUtils;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	public class LayerBitmapTile extends LayerConventional
	{
		private var _bmd:BitmapData;
		private var _tiled:Boolean;
		private var _smoothed:Boolean;
		
		public function LayerBitmapTile(bmd:*=null, tile:Boolean=true, smooth:Boolean=false)
		{
			super();
			
			_tiled = tile;
			_smoothed = smooth;
			
			if(bmd is BitmapData)
			{
				_bmd = bmd;
			} else if (bmd is String)
			{
				this.loadBitmapFromUrl( bmd );
			}
		}
		
		public function get bitmapData():BitmapData { return _bmd; }
		public function set bitmapData( value:BitmapData ):void { _bmd = value; }
		
		public function get tiled():Boolean { return _tiled; }
		public function set tiled(value:Boolean):void { _tiled = value; }
		
		public function get smoothed():Boolean { return _smoothed; }
		public function set smoother(value:Boolean):void { _smoothed = value; }
		
		public function loadBitmapFromUrl( url:String ):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bitmapDataLoaded );
			loader.load( new URLRequest( url ) );
		}
		
		private function bitmapDataLoaded(e:Event):void
		{
			var info:LoaderInfo = e.currentTarget as LoaderInfo;
			var loader:Loader = info.loader;
			
			info.removeEventListener(Event.COMPLETE, bitmapDataLoaded );
			
			var bmp:Bitmap = loader.content as Bitmap;
			if (bmp)
			{
				this.bitmapData = bmp.bitmapData;
			}
		}
		
		
		override public function render(mat:Matrix=null):void
		{
			super.render(mat);
			
			this.graphics.clear();
			
			if(this.bitmapData && this.gameScreen && this.stage )
			{
				var ul:Point = LoDDisplayObjUtils.localToLocal( this.gameScreen.renderRect.topLeft, this.gameScreen, this );
				var br:Point = LoDDisplayObjUtils.localToLocal( this.gameScreen.renderRect.bottomRight, this.gameScreen, this );
				var pnt:Point = new Point();
				pnt.x = (ul.x < br.x) ? ul.x : br.x;
				pnt.y = (ul.y < br.y) ? ul.y : br.y;
				var w:Number = Math.abs(br.x - ul.x);
				var h:Number = Math.abs(br.y - ul.y);
				
				this.graphics.beginBitmapFill( this.bitmapData, null, this.tiled, this.smoothed );
				this.graphics.drawRect( pnt.x, pnt.y, w, h );
				this.graphics.endFill();
				
				//other way of doing it, not sure which is faster yet, I'm assuming the prior
				/* var m:Matrix = LoDDisplayObjUtils.getInverseConcatenatedMatrixThroughList( this, this.gameScreen );
				var rect:Rectangle = LoDMath.transformRectByMatrix( this.gameScreen.renderRect, m );
				
				this.graphics.beginBitmapFill( this.bitmapData );
				this.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
				this.graphics.endFill(); */
			}
		}
	}
}