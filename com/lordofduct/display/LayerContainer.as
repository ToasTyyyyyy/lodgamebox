/**
 * LayerContainer - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * When considering LayerContainers to ALSO contain other DisplayObject's that may or may not be LayerConventional 
 * objects, be forwarned that LayerConventionals are asserted at the BOTTOM of the DisplayList. If you add a DisplayObject 
 * underneath a layer it will appear underneath the LayerConventionals until another LayerConventional is added, at which time 
 * ALL LayerConventionals are again pushed to the bottom of the DisplayList.
 * 
 * LayerContainer should really only be used as JUST A CONTAINER. Avoid adding other DisplayObjects to a LayerContainer. You may notice 
 * nearly all Layer objects extend the base LayerConventional instead of LayerContainer which renders parenting useless for most layers.
 */
package com.lordofduct.display
{
	import com.lordofduct.util.Assertions;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	
	public class LayerContainer extends LayerConventional
	{
		private var _layers:Array = new Array();
		
		public function LayerContainer()
		{
			super();
		}
		
/**
 * Public Properties
 */
		public function get numLayers():int { return _layers.length; }
/**
 * Public Methods
 */
		public function setInternalMask(obj:DisplayObject):void
		{
			this.mask = obj;
			super.addChild(obj);
		}
		
		public function addLayer( layer:LayerConventional ):LayerConventional
		{
			if(!layer) return null;
			
			if (this.containsLayer( layer )) this.removeLayer( layer );
			
			_layers.push( layer );
			this.reassertLayers();
			
			return layer;
		}
		
		public function addLayerAt( layer:LayerConventional, index:int ):LayerConventional
		{
			if(!layer) return null;
			
			if (this.containsLayer( layer )) this.removeLayer( layer );
			
			index = LoDMath.clamp( index, this.numLayers );
			
			_layers.splice( index, 0, layer );
			this.reassertLayers();
			
			return layer;
		}
		
		public function containsLayer( layer:LayerConventional ):Boolean
		{
			Assertions.notNil( layer, "com.lordofduct.display::LayerContainer - can not check validity of null reference" );
			
			return Boolean( _layers.indexOf( layer ) >= 0 );
		}
		
		public function getLayerAt( index:int ):LayerConventional
		{
			return _layers[index];
		}
		
		public function getLayerIndex( layer:LayerConventional ):int
		{
			Assertions.notNil( layer, "com.lordofduct.display::LayerContainer - can not check validity of null reference" );
			
			return _layers.indexOf( layer );
		}
		
		public function removeLayer( layer:LayerConventional ):LayerConventional
		{
			Assertions.isTrue( this.containsLayer(layer), "com.lordofduct.display::LayerContainer - can not remove a layer that is not a child of this object.", Error );
			
			var index:int = _layers.indexOf( layer);
			if (index >= 0) _layers.splice( index, 1 );
			if (layer.gameScreen == this.gameScreen) layer.setGameScreen(null);
			if (this.contains(layer)) super.removeChild(layer);
			
			return layer;
		}
		
		public function removeLayerAt( index:int ):LayerConventional
		{
			Assertions.isTrue( Boolean( this.numLayers ), "com.lordofduct.display::LayerContainer - can not remove layers from an empty container.", Error );
			
			index = LoDMath.clamp(index, this.numLayers - 1);
			var layer:LayerConventional = _layers.splice( index, 1 )[0];
			if (layer && this.contains(layer))
			{
				layer.setGameScreen( null );
				return super.removeChild(layer) as LayerConventional;
			} else {
				return null;
			}
		}
		
		public function setLayerIndex( layer:LayerConventional, index:int ):void
		{
			this.removeLayer( layer );
			this.addLayerAt( layer, index );
			
			this.reassertLayers();
		}
		
		public function swapLayers( layer1:LayerConventional, layer2:LayerConventional ):void
		{
			var index1:int = this.getLayerIndex(layer1);
			var index2:int = this.getLayerIndex(layer2);
			
			Assertions.greater( index1, -1, "com.lordofduct.display::LayerContainer - can not remove a layer that is not a child of this object.", Error );
			Assertions.greater( index2, -1, "com.lordofduct.display::LayerContainer - can not remove a layer that is not a child of this object.", Error );
			
			_layers[index1] = layer2;
			_layers[index2] = layer1;
			
			this.reassertLayers();
		}
		
		public function swapLayersAt( index1:int, index2:int ):void
		{	
			Assertions.isTrue( Boolean( this.numLayers > 0 ), "com.lordofduct.display::LayerContainer - can not remove layers from an empty container.", Error );
			
			index1 = LoDMath.clamp(index1, this.numLayers);
			index2 = LoDMath.clamp(index2, this.numLayers);
			
			var layer1:LayerConventional = this.getLayerAt(index1);
			var layer2:LayerConventional = this.getLayerAt(index2);
			
			_layers[index1] = layer2;
			_layers[index2] = layer1;
			
			this.reassertLayers();
		}
		
		public function sortLayersBy( fieldName:Object, options:Object ):void
		{
			_layers.sortOn( fieldName, options );
			this.reassertLayers();
		}
		
		/**
		 * Layers with a smaller depthRatio will appear behind others
		 */
		public function sortLayersOnDepthRatio():void
		{
			_layers.sortOn("depthRatio", Array.NUMERIC);
			this.reassertLayers();
		}
		
/**
 * Private Interface
 */
		private function reassertLayers():void
		{
			var i:int = _layers.length;
			while(i--)
			{
				var layer:LayerConventional = _layers[i] as LayerConventional;
				layer.setGameScreen(this.gameScreen);
				super.addChildAt(layer, 0);
			}
		}
		
/**
 * Overrides
 */
		override public function render(mat:Matrix=null):void
		{
			super.render();
			
			for each( var layer:LayerConventional in _layers )
			{
				layer.render(mat);
			}
		}
		
		override internal function setGameScreen(screen:GameScreen):void
		{
			super.setGameScreen(screen);
			
			for each( var layer:LayerConventional in _layers )
			{
				layer.setGameScreen( screen );
			}
		}
		
	/**
	 * DIsplayObjectContainer overrides
	 */
		override public function addChild(child:DisplayObject):DisplayObject
		{
			Assertions.compatible( child, LayerConventional, "com.lordofduct.display::LayerContainer - children must be of type LayerConventional." );
			
			return this.addLayer( child as LayerConventional );
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			Assertions.compatible( child, LayerConventional, "com.lordofduct.display::LayerContainer - children must be of type LayerConventional." );
			
			return this.addLayerAt( child as LayerConventional, index );
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			Assertions.compatible( child, LayerConventional, "com.lordofduct.display::LayerContainer - children must be of type LayerConventional." );
			
			return this.removeLayer( child as LayerConventional );
		}
		
		override public function removeChildAt(index:int):DisplayObject
		{
			return this.removeLayerAt(index);
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			Assertions.compatible( child, LayerConventional, "com.lordofduct.display::LayerContainer - children must be of type LayerConventional." );
			
			this.setLayerIndex( child as LayerConventional, index );
		}
		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			Assertions.compatible( child1, LayerConventional, "com.lordofduct.display::LayerContainer - children must be of type LayerConventional." );
			Assertions.compatible( child2, LayerConventional, "com.lordofduct.display::LayerContainer - children must be of type LayerConventional." );
			
			this.swapLayers( child1 as LayerConventional, child2 as LayerConventional );
		}
		
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			this.swapLayersAt( index1, index2 );
		}
	}
}