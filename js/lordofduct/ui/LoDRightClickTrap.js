/**
 * LoDRightClickTrap - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Singleton Class written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * This is an expansion upon a script written by Uza in 2007
 * 
 * Original Author - Paulius Uza
 * blogsite - http://www.uza.lt
 * blogentry - http://www.uza.lt/blog/2007/08/solved-right-click-in-as3/
 * original source project - http://code.google.com/p/custom-context-menu/
 * 
 * Included expansion is inclussion of mouseUp events, trimmed down fat, and integration with 
 * the flash Event pool.
 * 
 * 
 * Example:
 * 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>Right Click Trap Example</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<script type="text/javascript" src="swfobject.js"></script>
		<script type="text/javascript" src="LoDRightClickTrap.js"></script>
		<script type="text/javascript">
		var params = {};
		params.quality = "high";
		params.name = "test";
		params.AllowScriptAccess = "always";//NECESSARY PART!!! 'sameDomain' works as well
		params.wmode = "opaque";
		
		swfobject.embedSWF("RightClickProject.swf", "flashcontent", "800", "600", "9.0.0", "expressInstall.swf", null, params);
		LoDRightClickTrap.init("flashcontent");
		</script>
	</head>
	<body>
		<div id="flashcontent">
			<h1>Alternative content</h1>
			<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
		</div>
	</body>
</html>
 * 
 * 
 * 
 * 
 */var LoDRightClickTrap = {
	objectId: "",
	
	init: function(objId) {
		this.objectId = objId;
		
		if(window.addEventListener){
			 window.addEventListener("mousedown", this.onGeckoMouseDown, true);
			 window.addEventListener("mouseup", this.onGeckoMouseUp, true);
			 
		} else {
			document.onmousedown = this.onIEMouseDown;
			document.oncontextmenu = this.trapContextMenu;
			document.onmouseup = this.onIEMouseUp;
		}
	},
	
	deinit: function() {
		if(window.RemoveEventListener){
			window.RemoveEventListener("mousedown",this.onGeckoMouseDown,true);
			window.addEventListener("mouseup", null, true);
			window.RemoveEventListener("mouseup", this.onGeckoMouseUp, true);
		} else {							
			document.onmouseup = null;
			document.oncontextmenu = null;
			document.onmousedown = null;
		}
		
		this.objectId = null;
	},
	
	call: function(type) {
		document.getElementById(this.objectId).rightMouseButtonTrap(type);
	},
	
	/**
	 * Event Listeners for Gecko style capture.
	 * 
	 * Support for non-IE browsers
	 */
	onGeckoMouseDown: function (e) {
		if (e.button != 0) {
			LoDRightClickTrap.killEvents(e);
			if(e.target.id == LoDRightClickTrap.objectId) {
				LoDRightClickTrap.call("mousedown");
			}
		}
	},
	
	onGeckoMouseUp: function (e) {
		if (e.button != 0) {
			LoDRightClickTrap.killEvents(e);
			if(e.target.id == LoDRightClickTrap.objectId) {
				LoDRightClickTrap.call("mouseup");
			}
		}
	},

	killEvents: function(eventObject) {
		if(eventObject) {
			if (eventObject.stopPropagation) eventObject.stopPropagation();
			if (eventObject.preventDefault) eventObject.preventDefault();
			if (eventObject.preventCapture) eventObject.preventCapture();
	   		if (eventObject.preventBubble) eventObject.preventBubble();
		}
	},
	
	/**
	 * Event Listeners for IE style capture
	 * 
	 * Support for IE browsers
	 */
	onIEMouseDown: function() {
		var ev = window.event;
		
		if (ev.button > 1) {
			if(ev.srcElement.id == LoDRightClickTrap.objectId) {
				LoDRightClickTrap.call("mousedown");
				document.setCapture();
			}
		}
	},
	
	trapContextMenu: function() {
		var ev = window.event;
		if(ev.srcElement.id == LoDRightClickTrap.objectId) return false;
	},
	
	onIEMouseUp: function() {
		var ev = window.event;
		document.releaseCapture();
		if (ev.button > 1) {
			if(ev.srcElement.id == LoDRightClickTrap.objectId) {
				LoDRightClickTrap.call("mouseup");
			}
		}
	}
}