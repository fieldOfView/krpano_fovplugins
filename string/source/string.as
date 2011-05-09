/*
string plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/string/plugin.html
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

	public class string extends Sprite {
		private var krpano:krpano_as3_interface = null;
		public var plugin_object:Object = null;
				
		public function string() {
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
				txt.htmlText = "<b>string plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
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
			
			return;
		}

		private function stopPlugin(event:Event) : void {
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			
			this.plugin_object = null;
			this.krpano = null;
			return;
		}
		
		private function registerPlugin(event:DataEvent) : void {
			this.plugin_object = this.krpano.get(event.data);
			
			this.plugin_object.registerattribute("txtlength", this.interface_length);
			this.plugin_object.registerattribute("txtchunk", this.interface_substr);
			this.plugin_object.registerattribute("txtfind", this.interface_indexof);
			this.plugin_object.registerattribute("txtreplace", this.interface_replace);
			this.plugin_object.registerattribute("txttrim", this.interface_trim);
			this.plugin_object.registerattribute("txtlower", this.interface_lowercase);
			this.plugin_object.registerattribute("txtupper", this.interface_uppercase);
			
			return;
		}

		public function interface_length(varname:String = "", subject:String = "") : void {
			// return the length of the supplied text
			this.krpano.set(varname, subject.length );
		}

		public function interface_substr(varname:String = "", subject:String = "", startIndex:Number = 0, len:Number = 0x7FFFFFFF) : void {
			// return a substring of the supplied text
			this.krpano.set(varname, subject.substr(startIndex, len) );
		}
		
		public function interface_indexof(varname:String = "", subject:String = "", find:String = "") : void {
			// find a needle in a haystack and return its position
			this.krpano.set(varname, subject.indexOf(find) );
		}
		
		public function interface_replace(varname:String = "", subject:String = "", find:String = "", replace:String = "", flags:String = "gi") : void {
			// find and replace a needle in a haystack
			var pattern:RegExp = new RegExp(find, flags);
			this.krpano.set(varname, subject.replace(pattern, replace) );
		}
		
		public function interface_trim(varname:String = "", subject:String = null) : void {
			var pattern:RegExp = /^[\s|\t|\n]+|[\s|\t|\n]+$/g;
			this.krpano.set(varname, ((subject!=null)?subject:this.krpano.get(varname)).replace(pattern, "") );
		}
		
		public function interface_lowercase(varname:String = "", subject:String = null) : void {
			this.krpano.set(varname, ((subject!=null)?subject:this.krpano.get(varname)).toLowerCase() );
		}
		public function interface_uppercase(varname:String = "", subject:String = null) : void {
			this.krpano.set(varname, ((subject!=null)?subject:this.krpano.get(varname)).toUpperCase() );
		}
	}
}