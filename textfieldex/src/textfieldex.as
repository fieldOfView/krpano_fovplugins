/*
extended textfield plugin for KRPano
by Aldo Hoeben / fieldOfView.com
	based on textfield by Klaus / krpano.com

http://fieldofview.github.com/krpano_fovplugins/misc/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

package
{
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.net.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.xml.*;
	import flash.ui.Mouse;

	import krpano_as3_interface;

	// SWF Metadata
	[SWF(width="256", height="256", backgroundColor="#000000")]
	
	public class textfieldex extends Sprite
	{
		// krpano as3 interface
		private var krpano:krpano_as3_interface = null;
		private var parsePath:Function = null;

		public var pluginpath : String = null;
		public var pluginobj  : Object = null;

		public var bg        : Shape     = null;
		public var txt       : TextField = null;
		
		public var txt_width  : int = 256;
		public var txt_height : int = 256;
		
		private var usercontrol   : String = "";
		private var keyboardupdate: Boolean = false;
		
		public function textfieldex()
		{
			if (stage == null) {
				this.addEventListener(Event.ADDED_TO_STAGE, startplugin);
				this.addEventListener(Event.UNLOAD, stopplugin);
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
				txt.htmlText = "<b>textfieldex plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
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



		private function startplugin(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, startplugin);

			if (krpano == null)
			{
				// get krpano interface
				krpano = krpano_as3_interface.getInstance();
				parsePath = krpano.get("parsepath");

				if ( krpano.get("version") < "1.0.8" )
				{
					krpano.call("error(textfieldex plugin - wrong krpano version - min. 1.0.8 needed);");
					return;
				}

				// add krpano plugin listeners

				// register event to get the krpano name of the plugin
				krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, registerEvent);

				// resize event to set the size of the textfield
				krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_RESIZE,   resizeEvent);
				krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE,   updateEvent);
			}
		}



		private function stopplugin(evt:Event):void
		{
			// remove textfield event listeners
			txt.removeEventListener(TextEvent.LINK, link_event);
			txt.removeEventListener(Event.CHANGE, change_event);
			txt.removeEventListener(MouseEvent.CLICK, click_event);
			txt.removeEventListener(FocusEvent.FOCUS_IN, focusin_event);
			txt.removeEventListener(FocusEvent.FOCUS_OUT, focusout_event);
			txt.removeEventListener(KeyboardEvent.KEY_DOWN, keydown_event);

			// remove krpano event listeners
			krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, registerEvent);
			krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_RESIZE,   resizeEvent);
			krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_UPDATE,   updateEvent);

			// remove all elements
			removeChild(bg);
			bg = null;

			removeChild(txt);
			txt = null;

			krpano = null;
		}



		private function registerEvent(evt:DataEvent):void
		{
			// register event - "evt.data" is the krpano xml name/path of the plugin (e.g. "plugin[txt1]" or "hotspot[textspot1]")

			pluginpath = evt.data;
			pluginobj  = krpano.get(pluginpath);		// get the whole krpano plugin object

			// register custom attributes with their default value (note - only lowercase attributes are possible!!!)
			pluginobj.registerattribute("html",            "");
			pluginobj.registerattribute("text",            "");
			pluginobj.registerattribute("css",             "");
			pluginobj.registerattribute("scale",           1);
			pluginobj.registerattribute("scaletext",       false);
			pluginobj.registerattribute("autosize",        "none");
			pluginobj.registerattribute("autosizemargin",  4);
			pluginobj.registerattribute("autowidth",       false);
			pluginobj.registerattribute("autowidthmargin", 4);
			pluginobj.registerattribute("minwidth",        0);
			pluginobj.registerattribute("minheight",       0);
			pluginobj.registerattribute("wordwrap",        true);
			pluginobj.registerattribute("multiline",       true);
			pluginobj.registerattribute("background",      true);
			pluginobj.registerattribute("backgroundcolor", 0xFFFFFF);
			pluginobj.registerattribute("backgroundalpha", 1.0);
			pluginobj.registerattribute("border",          false);			// new in 1.0.8.12
			pluginobj.registerattribute("bordercolor",     0x000000);
			pluginobj.registerattribute("borderalpha",     1.0);
			pluginobj.registerattribute("borderwidth",     1);
			pluginobj.registerattribute("borderjoints",    "round");
			pluginobj.registerattribute("roundedge",       0);
			pluginobj.registerattribute("selectable",      true);
			pluginobj.registerattribute("editable",        false);
			pluginobj.registerattribute("password",        false);
			pluginobj.registerattribute("quality",         "normal");
			pluginobj.registerattribute("glow",            0);
			pluginobj.registerattribute("glowalpha",       1);
			pluginobj.registerattribute("glowcolor",       0xFFFFFF);
			pluginobj.registerattribute("blur",            0);
			pluginobj.registerattribute("shadow",          0);
			pluginobj.registerattribute("shadowangle",     45);
			pluginobj.registerattribute("shadowcolor",     0x000000);
			pluginobj.registerattribute("shadowalpha",     1);
			pluginobj.registerattribute("shadowblur",      0);
			pluginobj.registerattribute("textglow",        0);
			pluginobj.registerattribute("textglowalpha",   1);
			pluginobj.registerattribute("textglowcolor",   0xFFFFFF);
			pluginobj.registerattribute("textblur",        0);
			pluginobj.registerattribute("textshadow",      0);
			pluginobj.registerattribute("textshadowangle", 45);
			pluginobj.registerattribute("textshadowcolor", 0x000000);
			pluginobj.registerattribute("textshadowalpha", 1);
			pluginobj.registerattribute("textshadowblur",  0);

			// add custom functions / link a krpano xml function to a as3 function (note - the name of the xml function must be lowercase!!!)
			pluginobj.update = updateHTML;

			// create a background shape for the textfield
			bg = new Shape();

			// create the as3 textfield itself
			txt = new TextField();
			txt.htmlText      = "";
			txt.multiline     = true;
			txt.wordWrap      = true;
			txt.border        = false;
			txt.background    = false;
			txt.condenseWhite = true;
			txt.width         = txt_width;
			txt.height        = txt_height;
			txt.scaleX        = 1;
			txt.scaleY        = 1;
			
			// textfield event listeners
			txt.addEventListener(TextEvent.LINK, link_event);
			txt.addEventListener(Event.CHANGE, change_event);
			txt.addEventListener(MouseEvent.CLICK, click_event);
			txt.addEventListener(FocusEvent.FOCUS_IN, focusin_event);
			txt.addEventListener(FocusEvent.FOCUS_OUT, focusout_event);
			
			// add background and textfield
			this.addChild(bg);
			this.addChild(txt);

			// update the style and content of the textfield
			updateSTYLE();
			updateHTML();
		}



		private function updateEvent(dataevent:DataEvent):void
		{
			// the update event sends the name of the changed attribute in the "dataevent.data" variable

			switch(dataevent.data) {
				case "text":
					txt.text = pluginobj.text;
					break;
			}
			
			// do here a quick search for the changed attribute and call the corresponding update function
			var changedattribute:String = "." + String( dataevent.data ) + ".";
			const data_attributes :String = ".text.html.css.";
			const style_attributes:String = ".scale.scaletext.autosize.autosizemargin.autowidth.autowidthmargin.minwidth.minheight.wordwrap.multiline.background.backgroundcolor.backgroundalpha.border.bordercolor.borderalpha.borderwidth.borderjoints.roundedge.selectable.editable.password.quality.glow.glowcolor.glowalpha.blur.shadow.shadowcolor.shadowalpha.shadowblur.shadowangle.textglow.textglowcolor.textglowalpha.textblur.textshadow.textshadowcolor.textshadowalpha.textshadowblur.textshadowangle.";

			if ( data_attributes.indexOf(changedattribute) >= 0 )
			{
				updateHTML();
			}
			else if ( style_attributes.indexOf(changedattribute) >= 0 )
			{
				updateSTYLE();
			}
		}



		private function resizeEvent(dataevent:DataEvent):void
		{
			var resizesize:String = dataevent.data;		// size has the format WIDTHxHEIGHT

			var width :int = parseInt(resizesize);
			var height:int = parseInt(resizesize.slice(resizesize.indexOf("x")+1));

			var margin:int = parseInt(pluginobj.autosizemargin);

			// set the size of the textfield
			txt.width  = width;
			txt.height = height;
			
			// save size
			txt_width  = width;
			if ( txt.autoSize != "none" ) 
				txt_height = txt.textHeight + margin;
			else
				txt_height = height + margin;
				
			if (stringToBoolean(pluginobj.scaletext))
			{
				txt.width  = width/pluginobj.scale;
				txt.height = height/pluginobj.scale;

				if ( txt.autoSize != "none" )
					txt_height = (txt.textHeight + margin) * pluginobj.scale;
			}

			// update background shape
			updateSTYLE();
		}



		private function link_event(textevent:TextEvent):void
		{
			// pass the text after the "event:" link to krpano

			krpano.call( textevent.text, null, pluginobj );
		}

		private function change_event(event:Event):void
		{
			if(pluginobj.html != txt.htmlText || pluginobj.text != txt.text) {
				pluginobj.html = txt.htmlText;
				pluginobj.text = txt.text;

				updateHTML();
			}
			
			if (pluginobj.onchange != null) 
			{
				krpano.call(pluginobj.onchange);
			}
		}		

		private function click_event(event:MouseEvent):void
		{
			if (pluginobj.onclick != null) 
			{
				krpano.call(pluginobj.onclick);
			}
		}

		private function focusin_event(event:FocusEvent):void
		{
			// disable keyboard navigation while editing text
			usercontrol = krpano.get("control.usercontrol");
			krpano.set("control.usercontrol", (usercontrol=="all" || usercontrol=="mouse")?"mouse":"off");

			txt.addEventListener(KeyboardEvent.KEY_DOWN, keydown_event);
			
			if (pluginobj.onfocus != null) 
			{
				krpano.call(pluginobj.onfocus);
			}
		}

		private function focusout_event(event:FocusEvent):void
		{
			// reenable keyboard navigation
			krpano.set("control.usercontrol", usercontrol);

			txt.removeEventListener(KeyboardEvent.KEY_DOWN, keydown_event);
			
			if (pluginobj.onblur != null) 
			{
				krpano.call(pluginobj.onblur);
			}
		}

		private function keydown_event(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case 79:
					// 'o'; inhibit showing/hiding the output window
					event.stopPropagation();
					break;
				case 13:
					// enter; if single line, call submit action
					if(!txt.multiline)
					{
						if (pluginobj.onsubmit != null) 
						{
							krpano.call(pluginobj.onsubmit);
						}
					}
					break;
			}
			keyboardupdate = true;
		}

		private function updateSTYLE():void
		{
			// pass the krpano parameters to the as3 textfield
			switch ( String( pluginobj.autosize ).toLowerCase() )
			{
				case "true":
				case "auto":
				case "left":  	txt.autoSize = "left";
								break;

				case "center":	txt.autoSize = "center";
								break;

				case "right": 	txt.autoSize = "right";
								break;

				case "none":
				default:      	txt.autoSize = "none";
								break;
			}

			txt.wordWrap   = stringToBoolean(pluginobj.wordwrap);
			txt.multiline  = (pluginobj.multiline != null)? stringToBoolean(pluginobj.multiline) : true;
			txt.selectable = stringToBoolean(pluginobj.selectable);
			txt.type       = stringToBoolean(pluginobj.editable)?TextFieldType.INPUT:TextFieldType.DYNAMIC;
			txt.displayAsPassword = stringToBoolean(pluginobj.password);

			if(pluginobj.quality == 'high') 
			{
				txt.antiAliasType = AntiAliasType.ADVANCED;
				txt.gridFitType = GridFitType.PIXEL;
			}
			else
			{
				txt.antiAliasType = AntiAliasType.NORMAL;
				txt.gridFitType = GridFitType.NONE;
			}

			txt.mouseEnabled = (txt.selectable || txt.type==TextFieldType.INPUT);

			if(stringToBoolean(pluginobj.autowidth) && txt.autoSize != "none")
			{
				txt_width = txt.textWidth+parseInt(pluginobj.autowidthmargin);
				if(Number(pluginobj.minwidth) > 0)
					txt_width = Math.max(Number(pluginobj.minwidth), txt_width);
			}			

			// update/draw the background shape
			bg.alpha = pluginobj.backgroundalpha;

			bg.graphics.clear();

			// draw a background and/or border?
			if (pluginobj.background || pluginobj.border)
			{
				if (pluginobj.borderwidth > 0)
					bg.graphics.lineStyle(pluginobj.borderwidth, pluginobj.bordercolor, pluginobj.borderalpha, (pluginobj.quality == 'high'), 'normal', null, pluginobj.borderjoints );

				if (pluginobj.background)
					bg.graphics.beginFill(pluginobj.backgroundcolor);

				if (pluginobj.roundedge <= 0)
					bg.graphics.drawRect(0,0,txt_width,txt_height);
				else
					bg.graphics.drawRoundRect(0,0,txt_width,txt_height, pluginobj.roundedge);
			}


			// create and apply filters for the background shape
			var filters:Array = new Array();

			if (pluginobj.glow > 0)
			{
				// glow = glowing range
				// glowcolor = color of the glowing
				filters.push( new GlowFilter(pluginobj.glowcolor, pluginobj.glowalpha, pluginobj.glow,pluginobj.glow) );
			}

			if (pluginobj.blur > 0)
			{
				// blur = blur range
				filters.push( new BlurFilter(pluginobj.blur, pluginobj.blur) );
			}

			if (pluginobj.shadow > 0)
			{
				// shadow = shadow range
				filters.push( new DropShadowFilter(pluginobj.shadow, pluginobj.shadowangle, pluginobj.shadowcolor, pluginobj.shadowalpha, pluginobj.shadowblur) );
			}

			// set or remove the filters
			bg.filters = filters.length > 0 ? filters : null


			// create and apply filters for the text itself
			var textfilters:Array = new Array();

			if (pluginobj.textglow > 0)
			{
				// textglow = glowing range
				// textglowcolor = color of the glowing
				textfilters.push( new GlowFilter(pluginobj.textglowcolor, pluginobj.textglowalpha, pluginobj.textglow,pluginobj.textglow) );
			}

			if (pluginobj.textblur > 0)
			{
				// textblur = blur range
				textfilters.push( new BlurFilter(pluginobj.textblur,  pluginobj.textblur) );
			}

			if (pluginobj.textshadow > 0)
			{
				// textshadow = shadow range
				textfilters.push( new DropShadowFilter(pluginobj.textshadow, pluginobj.textshadowangle, pluginobj.textshadowcolor, pluginobj.textshadowalpha, pluginobj.textshadowblur) );
			}

			// set or remove the filters
			txt.filters = textfilters.length > 0 ? textfilters : null
			
			if (stringToBoolean(pluginobj.scaletext) > 0)
			{
				txt.scaleX = pluginobj.scale;
				txt.scaleY = pluginobj.scale;
			}
		}



		// string replace helper function
		private function str_replace( original:String, replace_with:String, replace:String  ):String
		{
			var array:Array = original.split(replace_with);
			return array.join(replace);
		}


		private function updateHTML():void
		{
			var css:StyleSheet = new StyleSheet();

			var cssdata :String = pluginobj.css;
			var htmldata:String = pluginobj.html;

			if (cssdata == null || cssdata == "")
			{
				txt.styleSheet = null;
			}
			else
			{
				if (cssdata.indexOf("data:") == 0 )
				{
					// load the content of a <data> tag
					cssdata = krpano.get("data[" + cssdata.slice(5) + "].content");
				}
				else
				{
					// directly use the given css
					cssdata = unescape(cssdata);
				}

				css.parseCSS( cssdata );
				if(!stringToBoolean(pluginobj.editable))
				{
					txt.styleSheet = css;
				}
				else
				{
					txt.defaultTextFormat = css.transform(css.getStyle("p"));
				}
			}

			if (htmldata.indexOf("data:") == 0 )
			{
				// load the content of a <data> tag
				htmldata = krpano.get("data[" + htmldata.slice(5) + "].content");
			}
			else
			{
				// directly use the given html
				
				if(keyboardupdate) 
				{
					// do not convert from [] to <> if this update was caused by keyboard input
					keyboardupdate = false;
				} else
				{
					// (<> chars are not possible in a xml attribure, therefore provide the usage of [] instead)

					// replace '[' -> '<'
					htmldata = str_replace(htmldata,"[","<");

					// replace ']' -> '>'
					htmldata = str_replace(htmldata,"]",">");
				}
				
				htmldata = unescape(htmldata);
			}

			if (htmldata == null || htmldata == "")
			{
				htmldata = "";
			}
 			else if(htmldata.charAt(1)!="<") 
			{
				htmldata = "<p>" + htmldata + "</p>";
			}

			txt.htmlText = htmldata;
			pluginobj.text = txt.text;


			if (txt.autoSize != "none")
			{
				// the as3 textfield autosizing is used

				// save size
				txt_height = txt.height;
				
				if(Number(pluginobj.minheight) > 0)
					txt_height = Math.max(Number(pluginobj.minheight), txt_height);

				//krpano.set(pluginpath + ".height", txt_height);
				pluginobj.height = txt_height;

				// the textfield unfortuntaly doesn't provide the right size immediately
				// therefore add a short delay to get the real size
				var updatetimer:Timer = new Timer(0.001,1);
				updatetimer.addEventListener("timer", updateSIZE);
				updatetimer.start();
			}

			// save the current text only height also to the xml as "textheight" variable
			//krpano.set(pluginpath + ".textheight", txt.textHeight);
			pluginobj.textheight = txt_height;
		}



		private function updateSIZE(te:TimerEvent=null):void
		{
			txt_height = txt.height;
			
			if(Number(pluginobj.minheight) > 0)
					txt_height = Math.max(Number(pluginobj.minheight), txt_height);

			//krpano.set(pluginpath + ".height",     txt_height);
			//krpano.set(pluginpath + ".textheight", txt.textHeight);
			// update the real textfield and text sizes in krpano
			pluginobj.height     = txt_height;
			pluginobj.textheight = txt.textHeight;

			// update the background shape
			updateSTYLE();
		}


		/*
		 * Helper functions
		 */		
		private function stringToBoolean(value:String) : Boolean 
		{ 
			// boolean cast helper 
			return (String("yesontrue1").indexOf( value.toLowerCase() ) >= 0); 
		};	
	}
}
