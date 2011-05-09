/*
misc plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/misc/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

package {
	import flash.display.*;
	import flash.text.*;	
	import flash.events.*;
	import flash.system.System;
	
	import krpano_as3_interface;

	// SWF Metadata
	[SWF(width="256", height="256", backgroundColor="#000000")]

	public class misc extends Sprite {
		private var krpano:krpano_as3_interface = null;
		public var plugin_object:Object = null;
		
		private var panosprite:Sprite = null;

		public function misc() {
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
				txt.htmlText = "<b>misc plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
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
			
			return;
		}

		private function stopPlugin(event:Event) : void {
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE, this.updatePlugin);
			
			this.plugin_object = null;
			this.krpano = null;
			return;
		}
		
		private function registerPlugin(event:DataEvent) : void {
			this.plugin_object = this.krpano.get(event.data);

			this.plugin_object.registerattribute("forloop", interface_for);			
			this.plugin_object.registerattribute("abs", interface_abs);
			this.plugin_object.registerattribute("max", interface_max);
			this.plugin_object.registerattribute("min", interface_min);
			
			return;
		}		

		private function updatePlugin(event:DataEvent) : void {
			switch(event.data) {
			}			
		}
		
		public function interface_for(varName:String="", startValue:Number=0, endValue:Number=0, stepValue:Number=0, iterate:String="") : void {
			// for-loop
			
			if(iterate == "" || stepValue==0)
				return;
			
			var value:Number = startValue;
			this.krpano.set(varName, value);
			
			while( (stepValue > 0 && value <= endValue) || (stepValue < 0 && value >= endValue) ) {
				this.krpano.call(iterate);
				value += stepValue;
				this.krpano.set(varName, value);
			}
			
			this.krpano.set(varName, endValue);
		}
		
		public function interface_abs(varName:String="", value:String=null) : void {
			// absolute value
			this.krpano.set(varName, Math.abs( Number((value!=null)?value:this.krpano.get(varName)) ) );
		}

		public function interface_max(varName:String="", ... values) : void {
			// largest value
			var value:Number = values[0];
			for(var i:int=1; i<values.length; i++) {
				value = Math.max(value, Number(values[i]));
			}
			this.krpano.set(varName, value );
		}		
		
		public function interface_min(varName:String="", ... values) : void {
			// smallest value
			var value:Number = values[0];
			for(var i:int=1; i<values.length; i++) {
				value = Math.min(value, Number(values[i]));
			}
			this.krpano.set(varName, value );
		}
	}
}