/**
 * LoDDisplayObjUtils - written by Dylan Engelman a.k.a LordOfDuct
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
 */
package com.lordofduct.util
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class LoDDisplayObjUtils
	{
		
		public function LoDDisplayObjUtils()
		{
			Assertions.throwError("com.lorofduct.util::LoDDisplayObjUtils - can not instantiate static member class.", Error);
		}
		
/**
 * Class Definition
 */
		/**
		 * TODO - rewrite to make more user friendly, at this point it really only serves stupid special cases
		 */
		public static function drawDisplayObjectAsIs( obj:DisplayObject, mat:Matrix=null, w:Number=NaN, h:Number=NaN ):Bitmap
		{
			if (!obj) return null;
			
			if(isNaN(w) || isNaN(h))
			{
				var rect:Rectangle = obj.getBounds( obj );
				
				if (!rect.width && isNaN(w) || !rect.height) return null;
				
				if(isNaN(w)) w =  Math.abs(rect.left) + rect.right;
				if(isNaN(h)) h = Math.abs(rect.top) + rect.bottom;
			}
			
			if(!mat) mat = obj.transform.matrix;
			var bmd:BitmapData = new BitmapData( w, h, true, 0x00000000);
			bmd.draw( obj, mat, null, null, null, true );
			
			return new Bitmap( bmd );
		}
		
		/**
		 * Transform point for local space of one display object to another
		 */
		public static function localToLocal( pnt:Point, start:DisplayObject, end:DisplayObject ):Point
		{
			return end.globalToLocal( start.localToGlobal( pnt ) );
		}
		
		/**
		 * Find the center of a DisplayObject with in its local space
		 */
		public static function findCenterOf( obj:DisplayObject ):Point
		{
			var rect:Rectangle = obj.getRect(obj);
			
			var pnt:Point = new Point();
			pnt.x = rect.left + ( rect.right - rect.left ) / 2;
			pnt.y = rect.top + ( rect.bottom - rect.top ) / 2;
			
			return pnt;
		}
		
		/**
		 * This is a peculiar method. It locates the center of a DisplayObject with respect to its local 
		 * space. But it takes into consideration any scaling, rotation, or skewing that may occur, it 
		 * doesn't consider any translation!
		 * 
		 * @param obj:DisplayObject - the object to find the center of
		 * @param ignoreTranslation:Boolean - should we ignore the (x,y) position of the object
		 * 
		 * Useful for locating the "center" of a DisplayObject who's (0,0) registration is not top-left aligned.
		 */
		public static function findTransformedCenterOf( obj:DisplayObject, ignoreTranslation:Boolean=true ):Point
		{
			var rect:Rectangle = obj.getRect( obj );
			var pnt:Point = new Point();
			
			pnt.x = rect.left + ( rect.right - rect.left ) / 2;
			pnt.y = rect.top + ( rect.bottom - rect.top ) / 2;
			
			return findTransformedPointOf( obj, pnt );
		}
		
		/**
		 * similar to findTransformedCenterOf. This method finds the position relative to a DisplayObject 
		 * taking into consideration all transformation except for translation.
		 * 
		 * @param obj:DisplayObject - the object to find the center of
		 * @param pnt:Point - the internal point
		 * @param ignoreTranslation:Boolean - should we ignore the (x,y) position of the object
		 * 
		 * Useful for locating points relative to a DisplayObject's registration point.
		 */
		public static function findTransformedPointOf( obj:DisplayObject, pnt:Point, ignoreTranslation:Boolean=true ):Point
		{
			var mat:Matrix = obj.transform.matrix;
			if(ignoreTranslation) mat.tx = mat.ty = 0;
			return mat.transformPoint( pnt );
		}
		
		/**
		 * Returns the transform matrix describing the child with relation to some parent container's space.
		 * 
		 * Essentially it concatenates the child's matrix with its parent's, and its parent's parent's matrix until it reaches 'endParent'.
		 * 
		 * @param child - the child DisplayObject to begin the concatenation with
		 * @param endParent - the containing parent in the DisplayList chain to end with
		 */
		public static function getConcatenatedMatrixThroughList( child:DisplayObject, endParent:DisplayObjectContainer ):Matrix
		{
			Assertions.isTrue( endParent.contains( child ), "com.lordofduct.util::LoDDisplayObjUtils - getConcatenatedMatrixThroughList(...), endParent MUST be some parent container to the child supplied" );
			
			var m:Matrix = child.transform.matrix;
			var par:DisplayObjectContainer = child.parent;
			
			while( par && par != endParent )
			{
				m.concat( par.transform.matrix );
				par = par.parent;
			}
			
			return m;
		}
		
		/**
		 * Returns the transform matrix describing the parent container with relation to some child's space.
		 * 
		 * Essentially it is the OPPOSITE of getConcatenatedThroughList(...)
		 * 
		 * @param child - the child DisplayObject to begin the concatenation with
		 * @param endParent - the containing parent in the DisplayList chain to end with
		 */
		public static function getInverseConcatenatedMatrixThroughList( child:DisplayObject, endParent:DisplayObjectContainer ):Matrix
		{
			var m:Matrix = getConcatenatedMatrixThroughList( child, endParent );
			m.invert();
			return m;
		}
/**
 * Container Organizing methods
 */
		/**
		 * Remove all the children of a DisplayObjectContainer
		 */
		public static function emptyContainer( cont:DisplayObjectContainer ):void
		{
			while( cont.numChildren ) cont.removeChildAt(0);
		}
		
		/**
		 * Remove all the children of a DisplayObjectContainer
		 * 
		 * every object that is removed can have a method ran on it referenced by name and args couplet.
		 * 
		 * Pass this as a series of objects as follows:
		 * 
		 * { method:String, params:Array }
		 * 
		 * for example:
		 * 
		 * DisplayObjectOrganizer.clearContainer( myContainer, { method:"removeEventListener", params:[ MouseEvent.CLICK, someFunction, false ] } );
		 */
		public static function clearContainer( cont:DisplayObjectContainer, ...args ):void
		{
			while( cont.numChildren )
			{
				var child:DisplayObject = cont.removeChildAt(0);
				
				for (var i:int = 0; args && i < args.length; i++ )
				{
					var obj:Object = args[i];
					child[obj.method].apply( child, obj.params );
				}
			}
		}
		
		/**
		 * Remove all the children of a DisplayObjectContainer and return them as an array.
		 * 
		 * First item in the array is at the bottom of the displayList, the last is at the top.
		 */
		public static function dumpContainer( cont:DisplayObjectContainer ):Array
		{
			var arr:Array = new Array();
			
			while( cont.numChildren ) arr.push( cont.removeChildAt(0) );
			
			return arr;
		}
		
		public static function breakApartContainer( cont:DisplayObjectContainer, removeCont:Boolean=false, use3d:Boolean=false ):void
		{
			if (!cont || !cont.parent) {
				return;
			}
			if(!cont.numChildren > 0)
			{
				if(removeCont) cont.parent.removeChild(cont);
				
				return;
			}
			    
			var pi:int=cont.parent.getChildIndex(cont);
			
			//if we are using 3d AND 3d is available...
			if(use3d && cont.transform.hasOwnProperty("matrix3D") && cont.hasOwnProperty("getRelativeMatrix3D"))
			{
				while(cont.numChildren)
				{
					var child3d:DisplayObject = cont.getChildAt(cont.numChildren - 1);
					//implicitly refer to the functions so there aren't compile errors in CS3 or the such
					var mat = child3d.transform["getRelativeMatrix3D"](cont);
					child3d.transform["matrix3D"] = mat;
					cont.removeChild(child3d);
					cont.parent.addChildAt(child3d,pi+1);
				}
			} else {     
				var pm:Matrix=cont.transform.matrix;
				   
				while (cont.numChildren)
				{        
					var child:DisplayObject=cont.removeChildAt(cont.numChildren - 1);
					  
					var m:Matrix=child.transform.matrix;
					m.concat(pm);
					child.transform.matrix=m;
					    
					cont.parent.addChildAt(child,pi+1);//we add the children just above the cont
					
				}
			}
			
			if(removeCont){
				cont.parent.removeChild(cont);
			}
		}
		
		/**
		 * Add a list of DisplayObjects from an Array to a DisplayObjectContainer.
		 * 
		 * First item in array is at the bottom of the displayList, the last is at the top.
		 * 
		 * Array is disposed of in the process, so if you would like to preserve array, clone it.
		 * 
		 * If object is not a DisplayObject a implicit coercion error is reported by DisplayObjectContainer.
		 */
		public static function fillContainer( cont:DisplayObjectContainer, arr:Array ):void
		{
			while( arr.length ) cont.addChild( arr.shift() );
		}
		
		/**
		 * Sort a DisplayObjectContainer's children.
		 * 
		 * Very similar to array.sort in that it actually dumps all children into an array, 
		 * applies the sort method with the passed 'args', and then pushes them all back into 
		 * the container.
		 */
		public static function sortChildren( cont:DisplayObjectContainer, ...args ):void
		{
			var arr:Array = dumpContainer( cont );
			
			arr.sort.apply( arr, args );
			
			fillContainer( cont, arr );
		}
		
		/**
		 * Sort a DisplayObjectContainer by a property of its children.
		 * 
		 * Very similar to Array.sortOn in that it actually dumps all children into an array, 
		 * applies the sortOn method with the passed arguments, and then pushes them all back into 
		 * the container.
		 * 
		 * Property must be relative to all children... so stick to properties available to DisplayObject.
		 */
		public static function sortOnChildren( cont:DisplayObjectContainer, fieldName:Object, options:Object=null  ):void
		{
			var arr:Array = dumpContainer( cont );
			
			arr.sortOn( fieldName, options );
			
			fillContainer( cont, arr );
		}
		
		/**
		 * Resize a DisplayObject while conserving aspect ratio
		 * 
		 * This method solves the aspect ratio of the passed object and the target width and height. 
		 * It then adjusts the passed width and height to meet the original aspect ratio and sets 
		 * those values to the DisplayObject so it fits IN the supplied width and height.
		 * 
		 * Use this when resizing images to fit in some width x height.
		 */
		public static function resizeDisplayObjectInsideRect( obj:DisplayObject, rect:Rectangle ):void
		{
			var w:Number = rect.width;
			var h:Number = rect.height;
			
			obj.transform.matrix = new Matrix();
			
			var aspect:Number = obj.width / obj.height;
			var tarAspect:Number = w / h;
			
			if (aspect == 0 || obj.height == 0) return new Matrix();
			
			if (tarAspect >= aspect)
			{
				w = h * aspect;
			} else
			{
				h = w / aspect;
			}
			
			var sx:Number = w / obj.width;
			var sy:Number = h / obj.height;
			var ix:Number = rect.x + (w - sx * obj.width) / 2;
			var iy:Number = rect.y + (h - sy * obj.height) / 2;
			obj.transform.matrix = new Matrix( sx, 0, 0, sy, ix, iy );
		}
		
		/**
		 * Resize a DisplayObject while conserving aspect ratio
		 * 
		 * This method solves the aspect ratio of the passed object and the target width and height. 
		 * It then adjusts the passed width and height to meet the original aspect ratio and sets 
		 * those values to the DisplayObject so it fits AROUND the supplied width and height.
		 * 
		 * Use this when resizing images to fit around some width x height.
		 */
		public static function resizeDisplayObjectAroundRect( obj:DisplayObject, rect:Rectangle ):void
		{
			var w:Number = rect.width;
			var h:Number = rect.height;
			
			obj.transform.matrix = new Matrix();
			
			var aspect:Number = obj.width / obj.height;
			var tarAspect:Number = w / h;
			
			if( aspect == 0 || obj.height == 0 ) return new Matrix();
			
			if( tarAspect <= aspect )
			{
				w = h * aspect;
			} else
			{
				h = w / aspect;
			}
			
			var sx:Number = w / obj.width;
			var sy:Number = h / obj.height;
			var ix:Number = rect.x + (w - sx * obj.width) / 2;
			var iy:Number = rect.y + (h - sy * obj.height) / 2;
			
			obj.transform.matrix = new Matrix( sx, 0, 0, sy, ix, iy );
		}
		
		
		public static function getResizeInsideMatrix( obj:DisplayObject, rect:Rectangle ):Matrix
		{
			var w:Number = rect.width;
			var h:Number = rect.height;
			
			var old:Matrix = obj.transform.matrix;
			obj.transform.matrix = new Matrix();
			
			var aspect:Number = obj.width / obj.height;
			var tarAspect:Number = w / h;
			
			if (aspect == 0 || obj.height == 0) return new Matrix();
			
			if (tarAspect >= aspect)
			{
				w = h * aspect;
			} else
			{
				h = w / aspect;
			}
			
			var sx:Number = w / obj.width;
			var sy:Number = h / obj.height;
			var ix:Number = rect.x + (w - sx * obj.width) / 2;
			var iy:Number = rect.y + (h - sy * obj.height) / 2;
			obj.transform.matrix = old;
			
			return new Matrix( sx, 0, 0, sy, ix, iy );
		}
		
		public static function getResizeAroundMatrix( obj:DisplayObject, rect:Rectangle ):Matrix
		{
			var w:Number = rect.width;
			var h:Number = rect.height;
			
			var old:Matrix = obj.transform.matrix;
			obj.transform.matrix = new Matrix();
			
			var aspect:Number = obj.width / obj.height;
			var tarAspect:Number = w / h;
			
			if( aspect == 0 || obj.height == 0 ) return new Matrix();
			
			if( tarAspect <= aspect )
			{
				w = h * aspect;
			} else
			{
				h = w / aspect;
			}
			
			var sx:Number = w / obj.width;
			var sy:Number = h / obj.height;
			var ix:Number = rect.x + (w - sx * obj.width) / 2;
			var iy:Number = rect.y + (h - sy * obj.height) / 2;
			
			obj.transform.matrix = old;
			
			return new Matrix( sx, 0, 0, sy, ix, iy );
		}
		
		
		
		
		
	/**
	 * Depricated crap
	 */
		public static function resizeDisplayObjectInside( obj:DisplayObject, w:Number, h:Number ):void
		{
			obj.scaleX = obj.scaleY = 1;
			var aspect:Number = obj.width / obj.height;
			var tarAspect:Number = w / h;
			
			if (aspect == 0 || obj.height == 0)
			{
				w = 0;
				h = 0;
			}
			if (tarAspect >= aspect)
			{
				w = h * aspect;
			} else
			{
				h = w / aspect;
			}
			
			obj.width = w;
			obj.height = h;
		}
		
		public static function resizeDisplayObjectAround( obj:DisplayObject, w:Number, h:Number ):void
		{
			obj.scaleX = obj.scaleY = 1;
			var aspect:Number = obj.width / obj.height;
			var tarAspect:Number = w / h;
			
			if (aspect == 0 || obj.height == 0)
			{
				w = 0;
				h = 0;
			}
			if (tarAspect <= aspect)
			{
				w = h * aspect;
			} else
			{
				h = w / aspect;
			}
			
			obj.width = w;
			obj.height = h;
		}
	}
}