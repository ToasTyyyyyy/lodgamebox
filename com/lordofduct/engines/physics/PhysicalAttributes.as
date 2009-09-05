package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.geom.LdTransform;
	import com.lordofduct.geom.Vector2;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class PhysicalAttributes extends EventDispatcher implements IPhysicalAttrib, IEventDispatcher
	{
		private var _view:DisplayObject;
		
		protected var _trans:LdTransform = new LdTransform();
		private var _targ:IPhysicalAttrib;
		private var _mesh:ICollisionMesh = null;
		
		private var _isRigBody:Boolean = false;
		
		private var _mass:Number = 1;
		private var _elast = 0;
		private var _frict = 0;
		
		public function PhysicalAttributes(target:IPhysicalAttrib=null)
		{
			_targ = (target) ? target : this;
			
			super(_targ);
			
			if(_targ is DisplayObject) _view = _targ as DisplayObject;
		}
/**
 * Properties
 */
	/**
	 * IVisibleObject Interface
	 */
		public function get view():DisplayObject { return _view; }
		public function set view(value:DisplayObject):void { _view = value; }
	/**
	 * IPhysicalAttrib Interface
	 */
		public function get physicalTransform():LdTransform { return _trans; }
		public function set physicalTransform(value:LdTransform):void { _trans = value; }
		
		public function get collisionMesh():ICollisionMesh { return _mesh; }
		public function set collisionMesh(value:ICollisionMesh):void { _mesh = value; }
		
		public function get isRigidBody():Boolean { return _isRigBody; }
		public function set isRigidBody(value:Boolean):void { _isRigBody = value; }
		
		public function get mass():Number { return _mass; }
		public function set mass(value:Number):void { _mass = value; }
		
		public function get invMass():Number { return 0; }
		
		public function get inertiaTensor():Number { return _mass; }
		public function get invInertiaTensor():Number { return 0; }
		
		public function get centerOfMass():Vector2
		{
			if(!_mesh) return new Vector2(_trans.x, _trans.y);
			
			return _mesh.getCenterOfMass(_trans.matrix);
		}
		
		public function get elasticity():Number { return _elast; }
		public function set elasticity(value:Number):void { _elast = value; }
		
		public function get friction():Number { return _frict; }
		public function set friction(value:Number):void { _frict = value; }
		
/**
 * Methods
 */
	}
}