package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;

	public class RodConstraint implements IForceSimulator
	{
		private var _base:IPhysicalAttrib;
		private var _rod:Vector2;
		private var _frict:Number;
		
		/**
		 * Base is any object to which you want to be constrained
		 * 
		 * rod is a Point or Point2D or Vector2 that represents a vector relative 
		 * to the base's local space to which you are constrained. The length of rod 
		 * is the distance an object will be constrained, and the direction is where 
		 * it will be from the bases registration point.
		 * 
		 * If base is scaled or rotated, rod is as well.
		 */
		public function RodConstraint(base:IPhysicalAttrib, rod:*, frict:Number=1)
		{
			_base = base;
			_rod = Vector2.copy( rod );
			_frict = LoDMath.clamp( frict, 1 );
		}
		
		public function get base():IPhysicalAttrib { return _base; }
		public function set base(value:IPhysicalAttrib):void { _base = value; }
		
		public function get rod():Vector2 { return _rod; }
		public function set rod(value:*):void { _rod.copy(value); }
		
		public function get friction():Number { return _frict; }
		public function set friction(value:Number):void { _frict = LoDMath.clamp( value, 1 ); }
		
		public function simulate(body:ISimulatableAttrib):void
		{
			//do nothing
		}
		
		public function constrain(body:ISimulatableAttrib):void
		{
			if(!base || !body) return;
			
			//TODO - make it so that the angles of the objects work out correctly
			
			var v:Vector2 = Vector2.rotateByMatrix( rod, base.physicalTransform.matrix );
			body.physicalTransform.x = base.physicalTransform.x + v.x;
			body.physicalTransform.y = base.physicalTransform.y + v.y;
		}
		
	}
}