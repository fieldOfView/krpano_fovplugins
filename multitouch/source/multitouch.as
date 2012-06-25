/*
multitouch zoom plugin for KRPano on Windows 7 and Android multitouch devices
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/multitouch/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

/*
 * NB: Android devices do not currently support MultitouchInputMode.GESTURE, so instead we have to
 * keep track of raw MultitouchInputMode.TOUCH_POINT events and distill pinch-gestures.
 */

package {
	import flash.display.*;
	import flash.text.*;	
	import flash.events.*;
	
	import flash.utils.*;
	import flash.system.*;
	
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import flash.geom.Point;
	
	import krpano_as3_interface;

	// SWF Metadata
	[SWF(width="256", height="256", backgroundColor="#000000")]

	public class multitouch extends Sprite {
		public var krpano : Object = null;
		public var plugin : Object = null;
		
		private var activeTouchPoints : Vector.<int> = new Vector.<int>();
		private var zoomTouchPoints : Vector.<int> = Vector.<int>([-1,-1]);
		private var touchPoints : Vector.<Point> = new Vector.<Point>();
		
		public function multitouch() {
			if (stage == null) {
				// startup when loaded inside krpano
				this.addEventListener(Event.ADDED_TO_STAGE, versioncheck);
			} else {
				// direct startup - show plugin version info
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				var format:TextFormat = new TextFormat();
				format.font = "_sans";
				format.size = 14;
				format.align = "center";
				var txt:TextField = new TextField();
				txt.textColor = 0xffffff;
				txt.selectable = false;
				txt.htmlText = "<b>multitouch zoom plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
				txt.autoSize = "center";
				txt.setTextFormat(format);
				addChild(txt);
				
				var resize:Function = function (event:Event) : void {
					txt.x = (stage.stageWidth - txt.width) / 2;
					txt.y = (stage.stageHeight - txt.height) / 2;
					return;
				}
			
				stage.addEventListener(Event.RESIZE, resize);
				resize(null);
			}
		}

		private function versioncheck(evt:Event):void {
			// compatibility check of the krpano version by using the old plugin interface:
			// - the "version" must be at least "1.0.8.14"
			// - and the "build" must be "2011-05-10" or greater
			this.removeEventListener(Event.ADDED_TO_STAGE, versioncheck);

			var oldkrpanointerface:Object = (getDefinitionByName("krpano_as3_interface") as Class)["getInstance"]();

			if (oldkrpanointerface.get("version") < "1.0.8.14" || oldkrpanointerface.get("build") < "2011-05-10") {
				oldkrpanointerface.trace(3, "multitouch plugin - krpano viewer version 1.0.8.14 or newer required");
			}
		}

		// registerplugin
		// - the start for the plugin
		// - this function will be called from krpano when the plugin will be loaded
		public function registerplugin(krpanointerface:Object, pluginfullpath:String, pluginobject:Object):void {
			// get the krpano interface and the plugin object
			krpano = krpanointerface;
			plugin = pluginobject;
			
			//Multitouch.inputMode = MultitouchInputMode.GESTURE;
			//pano.addEventListener(TransformGestureEvent.GESTURE_ZOOM, handleZoom); 
				
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin); 
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove); 
			stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);

			// add plugin attributes and functions
		}

		// unloadplugin
		// - the end for the plugin
		// - this function will be called from krpano when the plugin will be removed
		public function unloadplugin():void {
			// remove all your custom plugin stuff here
			//pano.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, handleZoom); 
			stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin); 
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove); 
			stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			
			plugin = null;
			krpano = null;
		}

		// onresize (optionally)
		// - this function will be called from krpano when the plugin will be resized
		// - can be used to resize sub elements manually
		// return:
		// - return true to let krpano scale the plugin automatically
		// - return false to disable any automatic scaling
		public function onresize(width:int, height:int):Boolean {
			return false;   // don't do any automatically scaling
		}
		
		/*
		private function handleZoom(event:TransformGestureEvent):void {
			var fov:Number = krpano.get("view.fov");
			krpano.set("view.fov", fov * event.scaleX);
		}
		*/
		
		private function onTouchBegin(event:TouchEvent):void {
			// keep track of which touchpoints are currently active
			activeTouchPoints.push(event.touchPointID);
			
			// extend touchPoints vector if necessary
			while(touchPoints.length <= event.touchPointID) {
				touchPoints.push(null);
			}
			touchPoints[event.touchPointID] = new Point(event.stageX, event.stageY);
			
			if(activeTouchPoints.length >= 2) {
				if( zoomTouchPoints[0] != activeTouchPoints[0] || zoomTouchPoints[1] != activeTouchPoints[1] ) {
					// new pair of touchpoints for zooming
					zoomTouchPoints = Vector.<int>([activeTouchPoints[0], activeTouchPoints[1]]);
				}
			}
		}
		
		private function onTouchMove(event:TouchEvent):void {
			if(zoomTouchPoints.indexOf(event.touchPointID) > -1) {
				// calculate distance between zoompoints before and after this event
				var previousDistance:Number = Point.distance(touchPoints[zoomTouchPoints[0]],touchPoints[zoomTouchPoints[1]]);
				touchPoints[event.touchPointID] = new Point(event.stageX, event.stageY);
				var newDistance:Number = Point.distance(touchPoints[zoomTouchPoints[0]],touchPoints[zoomTouchPoints[1]]);

				if(previousDistance > 0 && newDistance > 0) { 
					var fov:Number = krpano.get("view.fov");
					krpano.set("view.fov", fov * previousDistance / newDistance);
				}
			} else {
				// always keep track of all touchpoints, in case the zoompoints couple changes
				touchPoints[event.touchPointID] = new Point(event.stageX, event.stageY);
			}
		}
		
		private function onTouchEnd(event:TouchEvent):void {
			activeTouchPoints.splice(activeTouchPoints.indexOf(event.touchPointID),1);
			touchPoints[event.touchPointID] = null;

			if(activeTouchPoints.length >= 2) {
				if( zoomTouchPoints[0] != activeTouchPoints[0] || zoomTouchPoints[1] != activeTouchPoints[1] ) {
					// new pair of touchpoints for zooming
					zoomTouchPoints = Vector.<int>([activeTouchPoints[0], activeTouchPoints[1]]);
				}
			} else {
				// no longer zooming
				zoomTouchPoints = Vector.<int>([-1,-1]);
			}
		}
		
	}
}