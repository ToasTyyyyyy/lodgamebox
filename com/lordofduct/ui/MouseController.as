package com.lordofduct.ui
{
	import com.lordofduct.util.Assertions;
	
	import flash.display.InteractiveObject;
	
	public class MouseController extends GameController
	{
		private var _dispatcher:InteractiveObject;
		
		public function MouseController(idx:String, disp:InteractiveObject )
		{
			super(idx);
			
			this.registerDispatcher( disp );
			
			//TODO - actually make this damn thing!
		}
		
		public function registerDispatcher( disp:InteractiveObject ):void
		{
			Assertions.notNil(disp, "com.lordofduct.ui::MouseController - registerDispatcher(...) param disp must be non-null" );
			
			_dispatcher = disp;
		}
	}
}