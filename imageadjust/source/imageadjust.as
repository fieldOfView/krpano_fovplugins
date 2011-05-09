/*
imageadjust plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/imageadjust/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.BlurFilter;
	
	import krpano_as3_interface;
	import com.gskinner.geom.ColorMatrix;
	
	// SWF Metadata
	[SWF(width="256", height="256", backgroundColor="#000000")]

	public class imageadjust extends Sprite {
		private var krpano:krpano_as3_interface = null;
		public var plugin_object:Object = null;
		
		public var enabled:Boolean;
		public var brightness:Number = 0;
		public var contrast:Number = 0;
		public var hue:Number = 0;
		public var saturation:Number = 0;
		public var blurradius:Number = 0;
		
		private var colormatrix:ColorMatrix = new ColorMatrix();
		
		private var imagefilters:Array = [];
		
		private var panosprite:Sprite = null;
		
		public function imageadjust() {
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
				txt.htmlText = "<b>imageadjust plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
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
			
			this.panosprite = krpano.get("image.layer");
			this.colormatrix = new ColorMatrix();
			
			this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE, this.updatePlugin);
			
			return;
		}

		private function stopPlugin(event:Event) : void {
			// reset colortransform
			this.colormatrix = null;
			panosprite.filters = [];
			
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE, this.updatePlugin);
			
			this.plugin_object = null;
			this.krpano = null;
			return;
		}
		
		private function registerPlugin(event:DataEvent) : void {
			this.plugin_object = this.krpano.get(event.data);
			this.plugin_object.registerattribute("enabled", true);
			this.plugin_object.registerattribute("hue", 0);
			this.plugin_object.registerattribute("saturation", 0);
			this.plugin_object.registerattribute("brightness", 0);
			this.plugin_object.registerattribute("contrast", 0);
			this.plugin_object.registerattribute("blurradius", 0);

			this.plugin_object.registerattribute("adjust", interface_adjust);
			
			this.enabled =    (this.plugin_object.enabled!=null)?    Boolean(this.plugin_object.enabled):true;
			this.hue =        (this.plugin_object.hue!=null)?        Math.min(Math.max(this.plugin_object.hue,-180),180):0;
			this.saturation = (this.plugin_object.saturation!=null)? Math.min(Math.max(this.plugin_object.saturation,-1),1):0;
			this.brightness = (this.plugin_object.brightness!=null)? Math.min(Math.max(this.plugin_object.brightness,-1),1):0;
			this.contrast =   (this.plugin_object.contrast!=null)?   Math.min(Math.max(this.plugin_object.contrast,-1),1):0;
			this.blurradius = (this.plugin_object.blurradius!=null)? Math.max(this.plugin_object.blurradius,0):0;

			updateFilters();
				
			return;
		}		

		private function updatePlugin(event:DataEvent) : void {			
			switch(event.data) {
				case "enabled":
					this.enabled = Boolean(this.plugin_object.enabled);
					break;
				case "blurradius":
					this.blurradius = Math.max(this.plugin_object.blurradius, 0);
					break;
				case "hue":
					this.hue = Math.min(Math.max(this.plugin_object.hue,-180),180);
					break;
				case "saturation":
				case "brightness":
				case "contrast":
					this[event.data] = Math.min(Math.max(this.plugin_object[event.data],-1),1);
					break;
			}	
			updateFilters();			
		}

		private function updateFilters() : void {
			imagefilters = [];

			if (enabled) {
				if (hue!=0 || contrast!=0 || brightness!=0 || saturation!=0) {
					colormatrix.reset();
					/*
					colormatrix.adjustHue(hue);
					colormatrix.adjustContrast(contrast);
					colormatrix.adjustBrightness(100*brightness);
					colormatrix.adjustSaturation(saturation+1);
					imagefilters.push( colormatrix.filter );
					*/
					colormatrix.adjustColor(255*this.brightness, 100*this.contrast, 100*this.saturation, this.hue);
					imagefilters.push( new ColorMatrixFilter(colormatrix.toArray()) );
				}
				if (blurradius > 0) {
					imagefilters.push( new BlurFilter(this.blurradius, this.blurradius) );
				}
			}
			
			panosprite.filters = imagefilters;
		}
		
		public function interface_adjust(brightness:Number = 0, contrast:Number = 0, hue:Number = 0, saturation:Number = 0, blurradius:Number = 0) : void {
			this.brightness = Math.min(Math.max(brightness,-1),1);
			this.contrast =   Math.min(Math.max(contrast,-1),1);
			this.hue =        Math.min(Math.max(hue,-180),180);
			this.saturation = Math.min(Math.max(saturation,-1),1);
			this.blurradius = Math.max(blurradius,0);
			
			updateFilters();
		}
	}
}