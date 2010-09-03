package com.lordofduct.engines.physics
{
	import com.lordofduct.engines.physics.collisionMesh.ICollisionMesh;
	import com.lordofduct.geom.LdTransform;
	import com.lordofduct.geom.Vector2;
	import com.lordofduct.util.LoDMath;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	public class PhysicalAttributes extends EventDispatcher implements IPhysicalAttrib, IEventDispatcher
	{
		private var _view:DisplayObject;
		
		protected var _trans:LdTransform = new LdTransform();
		private var _targ:IPhysicalAttrib;
		private var _mesh:ICollisionMesh = null;
		
		private var _isRigBody:Boolean = false;
		
		private var _mass:Number = 1;
		private var _elast:Number = 0;
		private var _frict:Number = 0;
		
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
	 * ITransformable Interface
	 */
		public function get x():Number { return _trans.x; }
		public function set x(value:Number):void { _trans.x = value; }
		
		public function get y():Number { return _trans.y; }
		public function set y(value:Number):void { _trans.y = value; }
		
		public function get rotation():Number { return _trans.rotation * 180 / Math.PI; }
		public function set rotation( value:Number ):void { _trans.rotation = value * Math.PI / 180; }
		
		public function get scaleX():Number { return _trans.scaleX; }
		public function set scaleX(value:Number):void { _trans.scaleX = value; }
		
		public function get scaleY():Number { return _trans.scaleY; }
		public function set scaleY(value:Number):void { _trans.scaleY = value; }
		
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
		public function getPhysicalBounds():Rectangle
		{
			return (this.collisionMesh) ? LoDMath.transformRectByMatrix( this.collisionMesh.boundingRect, this.physicalTransform.matrix ) : new Rectangle();
		}
	}
}