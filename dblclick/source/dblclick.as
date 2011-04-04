/*
dblclick plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/dblclick/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

package {
	import flash.display.*;
	import flash.text.*;	
	import flash.events.*;
	
	import krpano_as3_interface;

	// SWF Metadata
	[SWF(width="256", height="256", backgroundColor="#000000")]

	public class dblclick extends Sprite {
		private var krpano:krpano_as3_interface = null;
		public var plugin_object:Object = null;
		
		public var ondblclick:String = "";
		
		private var panosprite:Sprite = null;

		public function dblclick() {
			if (stage == null) {
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			} else {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				var format:TextFormat = new TextFormat();
				format.font = "_sans";
				format.size = 14;
				format.align = "center";
				var txt:TextField = new TextField();
				txt.textColor = 0xffffff;
				txt.selectable = false;
				txt.htmlText = "<b>dblclick plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
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
			return;
		}
		
		private function startPlugin(event:Event) : void {
			this.krpano = krpano_as3_interface.getInstance();
			
			this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE, this.updatePlugin);

			this.panosprite = krpano.get("image.layer");
			this.panosprite.doubleClickEnabled = true;
			this.panosprite.addEventListener(MouseEvent.DOUBLE_CLICK, this.dblClickHandler);
			
			return;
		}

		private function stopPlugin(event:Event) : void {
			this.panosprite.removeEventListener(MouseEvent.DOUBLE_CLICK, this.dblClickHandler);
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE, this.updatePlugin);
			
			this.panosprite = null;
			this.plugin_object = null;
			this.krpano = null;
			return;
		}
		
		private function registerPlugin(event:DataEvent) : void {
			this.plugin_object = this.krpano.get(event.data);
			this.plugin_object.registerattribute("ondblclick", "");
			
			this.ondblclick = (this.plugin_object.ondblclick != null)? this.plugin_object.ondblclick:"";

			return;
		}		

		private function updatePlugin(event:DataEvent) : void {
			switch(event.data) {
				case "ondblclick":
					this.ondblclick = this.plugin_object.ondblclick;
					break;
			}			
		}

		private function dblClickHandler(event:MouseEvent) : void {	
			this.krpano.call(this.ondblclick);
		}
	}
}