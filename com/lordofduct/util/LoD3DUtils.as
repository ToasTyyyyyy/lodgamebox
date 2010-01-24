/**
 * 
 * REQUIRES FLEX 3.4 OR LATER!!! (Flash CS4 or later)
 */
package com.lordofduct.util
{
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	
	public class LoD3DUtils
	{
		public function LoD3DUtils()
		{
		}
		
		/**
		 * Removes the children of some container and places them in the parent in their relative positions.
		 * 
		 * @param cont - the container to remove children from
		 * @param removeCont - should the container be removed afterward
		 * @param force3D - forces manipulating the child as a 3d object
		 */
		public static function breakApartContainer( cont:DisplayObjectContainer, removeCont:Boolean=false, force3D:Boolean=false ):void
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
			while(cont.numChildren)
			{
				var child:DisplayObject = cont.getChildAt(cont.numChildren - 1);
				
				if(force3D || child.transform.matrix3D)
				{
					validateMatrix3D(child);
					var mat:Matrix3D = child.transform.getRelativeMatrix3D(cont.parent);
					child.transform.matrix3D = mat;
				} else {     
					var pm:Matrix=cont.transform.matrix;
					var m:Matrix=child.transform.matrix;
					m.concat(pm);
					child.transform.matrix=m;
				}
				
				cont.removeChild(child);
				cont.parent.addChildAt(child,pi+1);
			}
			
			if(removeCont){
				cont.parent.removeChild(cont);
			}
		}
		
		/**
		 * Tests if the displayObject is projected 3 dimensionally in any way. This is done 
		 * by cycling up the parent chain and seeing if any parent has a matrix3D attached.
		 */
		public static function isRendered3D(obj:DisplayObject):Boolean
		{
			if(obj.transform.matrix3D) return true;
			
			var par:DisplayObjectContainer = obj.parent;
			while(par)
			{
				if(par.transform.matrix3D) return true;
				
				par = par.parent;
			}
			
			return false;
		}
		
		/**
		 * Validate as 3d, if the object has a 2d matrix... it will create a 3d matrix from it 
		 * and set that as the new matrix.
		 */
		public static function validateMatrix3D(obj:DisplayObject):void
		{
			if(obj.transform.matrix3D) return;
			
			var m:Matrix = obj.transform.matrix;
			var vec:Vector.<Number> = Vector.<Number>([m.a,m.b,0,0, m.c,m.d,0,0, 0,0,1,0, m.tx,m.ty,0,1]);
			obj.transform.matrix3D = new Matrix3D(vec);
		}
	}
}