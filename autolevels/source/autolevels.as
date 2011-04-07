/*
autolevels plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/autolevels/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.geom.ColorTransform;
	
	import krpano_as3_interface;

	// SWF Metadata
	[SWF(width="256", height="256", backgroundColor="#000000")]

	public class autolevels extends Sprite {
		private var krpano:krpano_as3_interface = null;
		public var plugin_object:Object = null;
		
		public var enabled:Boolean;
		public var effect:Number;
		public var adaptation:Number;
		public var coloradjust:Number;
		public var attenuation:Number;
		public var threshold:Number;
		public var maxmultiplier:Number;

		public var levelsinvalid:Boolean = true;
		
		private var colortransform:ColorTransform = null;
		private var activecolortransform:ColorTransform = null;
		private var scalematrix:Matrix = null;
		
		private var panosprite:Sprite = null;
		private var meterbitmap:BitmapData = null;
				
		public function autolevels() {
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
				txt.htmlText = "<b>autolevels plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
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
			this.meterbitmap = new BitmapData(80,60,false);
	
			this.activecolortransform = new ColorTransform();

			// todo: only update scalematrix on screen resizes
			this.scalematrix = new Matrix();
			//this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_RESIZE, this.resizePlugin);
			//this.resizePlugin(null);
			
			this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE, this.updatePlugin);

			addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
			
			this.krpano.set("autolevels.onviewchange", this.viewChanged);
			var onviewchange:String = this.krpano.get("events.onviewchange");
			if (onviewchange == null)
				onviewchange = ""; 
			this.krpano.set("events.onviewchange", "autolevels.onviewchange();"+onviewchange);
			
			return;
		}

		private function stopPlugin(event:Event) : void {
			// reset colortransform
			this.colortransform = new ColorTransform();
			panosprite.transform.colorTransform = this.colortransform;
			
			removeEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE, this.updatePlugin);
			//this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_RESIZE, this.resizePlugin);
			
			var onviewchange:String = this.krpano.get("events.onviewchange");
			if (onviewchange == null)
				onviewchange = "";
			onviewchange = onviewchange.split("autolevels.onviewchange();").join("");
			this.krpano.set("events.onviewchange", onviewchange);
			
			this.plugin_object = null;
			this.krpano = null;
			return;
		}
		
		private function registerPlugin(event:DataEvent) : void {
			this.plugin_object = this.krpano.get(event.data);
			this.plugin_object.registerattribute("enabled", true);
			this.plugin_object.registerattribute("effect", Number(1));
			this.plugin_object.registerattribute("adaptation", Number(0.1));
			this.plugin_object.registerattribute("coloradjust", Number(1));
			this.plugin_object.registerattribute("threshold", Number(1));
			this.plugin_object.registerattribute("attenuation", Number(0));
			this.plugin_object.registerattribute("maxmultiplier", Number(10000));
			
			this.enabled = (this.plugin_object.enabled!=null)? Boolean(this.plugin_object.enabled):true;
			this.effect = (this.plugin_object.effect!=null)? Math.min(Math.max(Number(this.plugin_object.effect),0),1) : 1;
			this.adaptation = (this.plugin_object.adaptation!=null)? Math.min(Math.max(Number(this.plugin_object.adaptation),0.0001),1) : 0.1;
			this.coloradjust = (this.plugin_object.coloradjust!=null)? Math.min(Math.max(Number(this.plugin_object.coloradjust),0),10) : 1;
			this.threshold = (this.plugin_object.threshold!=null)? Math.min(Math.max(Number(this.plugin_object.threshold),0),255) : 1;
			this.attenuation = (this.plugin_object.threshold!=null)? Math.min(Math.max(Number(this.plugin_object.attenuation),0),0.999) : 0;
			this.maxmultiplier = (this.plugin_object.maxmultiplier!=null)? Math.max(Number(this.plugin_object.maxmultiplier),0) : 10000;

			return;
		}		

		private function updatePlugin(event:DataEvent) : void {
			// in any case, the meter bitmap needs to be recalculated
			this.levelsinvalid = true;
			
			switch(event.data) {
				case "enabled":
					this.enabled = Boolean(this.plugin_object.enabled);
					if(!this.enabled) {
						this.colortransform = new ColorTransform();
						this.activecolortransform = new ColorTransform();
					}
					break;
				case "effect":
					this.effect = Math.min(Math.max(Number(this.plugin_object.effect),0),1);
					break;
				case "adaptation":
					this.adaptation = Math.min(Math.max(Number(this.plugin_object.adaptation),0.0001),1);
					break;
				case "coloradjust":
					this.coloradjust = Math.min(Math.max(Number(this.plugin_object.coloradjust),0),10);
					break;
				case "threshold":
					this.threshold = Math.min(Math.max(Number(this.plugin_object.threshold),0),255);
					break;					
				case "attenuation":
					this.attenuation = Math.min(Math.max(Number(this.plugin_object.attenuation),0),0.999);
					break;					
				case "maxmultiplier":
					this.maxmultiplier = Math.max(Number(this.plugin_object.maxmultiplier),0);
					break;
			}			
		}

		private function enterFrameHandler(event:Event) : void {	
			if(this.enabled && this.levelsinvalid) {
				this.updateLevels();
			}
			
			this.activecolortransform.redMultiplier += (this.colortransform.redMultiplier - this.activecolortransform.redMultiplier) * adaptation;
			this.activecolortransform.redOffset += (this.colortransform.redOffset - this.activecolortransform.redOffset) * adaptation;
			this.activecolortransform.greenMultiplier += (this.colortransform.greenMultiplier - this.activecolortransform.greenMultiplier) * adaptation;
			this.activecolortransform.greenOffset += (this.colortransform.greenOffset - this.activecolortransform.greenOffset) * adaptation;
			this.activecolortransform.blueMultiplier += (this.colortransform.blueMultiplier - this.activecolortransform.blueMultiplier) * adaptation;
			this.activecolortransform.blueOffset += (this.colortransform.blueOffset - this.activecolortransform.blueOffset) * adaptation;
			
			this.panosprite.transform.colorTransform = this.activecolortransform;
			
			return;
		}

		private function resizePlugin(event:Event) : void {
			this.scalematrix.identity();
			var screenwidth:Number = krpano.get("view.r_screenwidth");
			var screenheight:Number = krpano.get("view.r_screenheight");
			this.scalematrix.translate( -screenwidth * attenuation/2, -screenheight * attenuation/2);
			this.scalematrix.scale( this.meterbitmap.width / screenwidth / (1-attenuation), this.meterbitmap.height / screenheight / (1-attenuation));	

			this.levelsinvalid = true;			
		}		
		
		private function viewChanged() : void {
			this.levelsinvalid = true;			
		}
		
		private function updateLevels() : void {
			// temporarily reset colortransform
			this.colortransform = new ColorTransform();
			panosprite.transform.colorTransform = this.colortransform;

			// copy sprite into small bitmapdata and get a histogram
			// todo: only update scalematrix on screen resizes
			this.resizePlugin(null);

			this.meterbitmap.draw(this.panosprite,this.scalematrix);
			var histogram:Vector.<Vector.<Number>> = meterbitmap.histogram();
			
			// analyse histogram
			var minvalues:Array = new Array();
			var maxvalues:Array = new Array();
			
			var channel:Number;
			for(channel = 0; channel<3; channel++) {
				for(var i:Number = 0; i<256; i++) {
					if(minvalues[channel]==null && histogram[channel][i]>this.threshold) {
						minvalues[channel] = i*this.effect;
					}
					if(maxvalues[channel]==null && histogram[channel][255-i]>this.threshold) {
						maxvalues[channel] = 255-(i*this.effect);
					}
					if(minvalues[channel]!=null && maxvalues[channel]!=null) {
						break;
					}
				}
			}
			
			// calculate greyscale values and mix with rgb channels
			minvalues[3] = (minvalues[0] + minvalues[1] + minvalues[2]) / 3;
			maxvalues[3] = (maxvalues[0] + maxvalues[1] + maxvalues[2]) / 3;
			for(channel = 0; channel<3; channel++) {
				minvalues[channel] = minvalues[channel] * this.coloradjust + minvalues[3] * (1-this.coloradjust);
				maxvalues[channel] = maxvalues[channel] * this.coloradjust + maxvalues[3] * (1-this.coloradjust);
			}
			
			this.colortransform.redMultiplier = Math.min(255.0 / (maxvalues[0] - minvalues[0]), this.maxmultiplier);
			this.colortransform.redOffset = - minvalues[0] * this.colortransform.redMultiplier;
			this.colortransform.greenMultiplier = Math.min(255.0 / (maxvalues[1] - minvalues[1]), this.maxmultiplier);
			this.colortransform.greenOffset = - minvalues[1] * this.colortransform.greenMultiplier;
			this.colortransform.blueMultiplier = Math.min(255.0 / (maxvalues[2] - minvalues[2]), this.maxmultiplier);
			this.colortransform.blueOffset = - minvalues[2] * this.colortransform.blueMultiplier;		
			
			this.levelsinvalid = false;
		}
	}
}