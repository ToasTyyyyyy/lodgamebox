package com.lordofduct.engines.physics.forces
{
	import com.lordofduct.engines.physics.IPhysicalAttrib;
	import com.lordofduct.engines.physics.ISimulatableAttrib;
	import com.lordofduct.geom.Vector2;

	public class TetherConstraint implements IForceSimulator
	{
		private var _base:IPhysicalAttrib;
		private var _len:Number;
		private var _offset:Vector2;
		
		public function TetherConstraint(base:IPhysicalAttrib, len:Number, offset:*=null)
		{
			_base = base;
			_len = len;
			_offset = (offset) ? Vector2.copy(offset) : Vector2.Zero;
		}
		
		public function get base():IPhysicalAttrib { return _base; }
		public function set base(value:IPhysicalAttrib):void { _base = value; }
		
		public function get length():Number { return _len; }
		public function set length(value:Number):void { _len = value; }
		
		public function get offset():Vector2 { return _offset; }
		public function set offset(value:*):void { _offset.copy(value); }

		public function simulate(body:ISimulatableAttrib):void
		{
			//TODO
		}
		
		public function constrain(body:ISimulatableAttrib):void
		{
			//currently a place holder, accomplishes very simple simulation
			var v:Vector2 = new Vector2();
			v.x = body.physicalTransform.x - base.physicalTransform.x;
			v.y = body.physicalTransform.y - base.physicalTransform.y;
			
			v.length = Math.min( v.length, _len );
			
			var vel:Vector2 = new Vector2( v.x - body.physicalTransform.x, v.y - body.physicalTransform.y );
			v.subtract(Vector2.rotateByMatrix(offset, body.physicalTransform.matrix));
			
			body.physicalTransform.x = base.physicalTransform.x + v.x;
			body.physicalTransform.y = base.physicalTransform.y + v.y;
			body.velocity.add(vel);
			
			//TODO - make this actually more realistic
		}
		
	}
}