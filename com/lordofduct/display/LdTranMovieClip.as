/**
 * LdTranMovieClip - written by Dylan Engelman a.k.a LordOfDuct
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
 * 
 * WARNING - AUTHOR DOES NOT LIKE THIS CLASS!
 * 
 * This class extends MovieClip and not LdTranSprite in any way. There is no simple way to extend LdTranSprite 
 * which would emulate the same hierarchy as the Flash DisplayObject hierarchy. 
 * 
 * I also dislike the whole idea because I personally find the MovieClip object to be a bloated and partially 
 * useless class except under certain stringant scenarios. I suggest utilizing the LdTranSprite family of objects 
 * as opposed to the MovieClip family unless you definately require MovieClip options (i.e. a timeline).
 * 
 * This MovieClip alternative merely exists for those of you who just can't live with out the MovieClip object type.
 */
package com.lordofduct.display
{
	import com.lordofduct.geom.LdTransform;
	import com.lordofduct.geom.SyncingLdTransform;
	import com.lordofduct.geom.SyncingTransform;
	import com.lordofduct.util.ITransformable;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.MovieClip;
	import flash.geom.Transform;

	dynamic public class LdTranMovieClip extends MovieClip implements ITransformable
	{
		protected var _trans:SyncingLdTransform = new SyncingLdTransform();
		
		public function LdTranMovieClip()
		{
			super();
			super.transform = SyncingTransform.createSyncingTransforms( this, this.transform, _trans );
		}
/**
 * DisplayObject Interpretor
 * 
 * All LdTranSprites are to have their position manipulated via the LdTransform as opposed to the standard Flash Transform object. 
 * These methods override the interface for the standard DisplayObject transform alterations and pushes them to LdTransform instead. 
 * 
 * protected method "updateFormalTransform()" handles updating the flash transform with the LdTransform.
 */
		public function get ldTransform():LdTransform { return _trans; }
		public function set ldTransform(value:LdTransform):void
		{
			_trans = new SyncingLdTransform( value.matrix, this.transform as SyncingTransform );
		}
	/**
	 * ITransformable Interface
	 * 
	 * DisplayObject overrides
	 * 
	 * this is to suppliment the inveritable update of transformations
	 */
		override public function set x(value:Number):void
		{
			_trans.x = value;
		}
		
		override public function set y(value:Number):void
		{
			_trans.y = value;
		}
		
		override public function set rotation(value:Number):void
		{
			_trans.rotation = value * LoDMath.DEG_TO_RAD;
		}
		
		override public function set scaleX(value:Number):void
		{
			_trans.scaleX = value;
		}
		
		override public function set scaleY(value:Number):void
		{
			_trans.scaleY = value;
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
			_trans.matrix = this.transform.matrix;
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			_trans.matrix = this.transform.matrix;
		}
		
		override public function set transform(value:Transform):void
		{
			super.transform = SyncingTransform.createSyncingTransforms( this, value, _trans );
		}
	}
}