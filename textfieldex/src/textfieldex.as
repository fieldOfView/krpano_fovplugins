/*
	krpano textfield plugin
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


	[SWF(width="400", height="300", backgroundColor="#000000")]
	public class textfieldex extends Sprite
	{
		// krpano as3 interface
		private var krpano:krpano_as3_interface = null;

		public var pluginpath : String = null;
		public var pluginobj  : Object = null;

		public var bg  : Shape     = null;
		public var txt : TextField = null;

		public var txt_width  : int = 400;
		public var txt_height : int = 300;



		public function textfieldex()
		{
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, startplugin);
				this.addEventListener(Event.UNLOAD,         stopplugin);
			}
			else
			{
				// direct startup - show version info
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align     = StageAlign.TOP_LEFT;

				var txt:TextField = new TextField();
				txt.textColor = 0xFFFFFF;
				txt.selectable = false;

				txt.htmlText =	"krpano " + "1.0.8.12" + "\n\n" +
								"<b>textfieldex plugin</b>"  + "\n\n" +
								"(build " + "CUSTOM" + ")";

				var f:TextFormat = new TextFormat();
				f.font = "_sans";
				f.size = 14;
				txt.autoSize = f.align = "center";
				txt.setTextFormat(f);

				addChild(txt);

				var resizefu:Function = function(event:Event):void
				{
					txt.x = (stage.stageWidth  - txt.width)/2;
					txt.y = (stage.stageHeight - txt.height)/2;
				}

				stage.addEventListener(Event.RESIZE, resizefu);

				resizefu(null);
			}
		}



		private function startplugin(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, startplugin);

			if (krpano == null)
			{
				// get krpano interface
				krpano = krpano_as3_interface.getInstance();

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
			// remove textfield link event listener
			txt.removeEventListener(TextEvent.LINK, link_event);

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
			pluginobj.registerattribute("css",             "");
			pluginobj.registerattribute("autosize",        "none");
			pluginobj.registerattribute("wordwrap",        true);
			pluginobj.registerattribute("background",      true);
			pluginobj.registerattribute("backgroundcolor", 0xFFFFFF);
			pluginobj.registerattribute("backgroundalpha", 1.0);
			pluginobj.registerattribute("border",          false);			// new in 1.0.8.12
			pluginobj.registerattribute("bordercolor",     0x000000);
			pluginobj.registerattribute("borderwidth",     1);
			pluginobj.registerattribute("roundedge",       0);
			pluginobj.registerattribute("selectable",      true);
			pluginobj.registerattribute("glow",            0);
			pluginobj.registerattribute("glowcolor",       0xFFFFFF);
			pluginobj.registerattribute("blur",            0);
			pluginobj.registerattribute("shadow",          0);
			pluginobj.registerattribute("textglow",        0);
			pluginobj.registerattribute("textglowcolor",   0xFFFFFF);
			pluginobj.registerattribute("textblur",        0);
			pluginobj.registerattribute("textshadow",      0);

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

			// textfield link event listener
			txt.addEventListener(TextEvent.LINK, link_event);

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

			// do here a quick search for the changed attribute and call the corresponding update function
			var changedattribute:String = "." + String( dataevent.data ) + ".";
			const data_attributes :String = ".html.css.";
			const style_attributes:String = ".autosize.wordwrap.background.backgroundcolor.backgroundalpha.border.bordercolor.borderwidth.roundedge.selectable.glow.blur.shadow.textglow.textblur.textshadow.";

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

			var width :int;
			var height:int;

			width  = parseInt(resizesize);
			height = parseInt(resizesize.slice(resizesize.indexOf("x")+1));

			// set the size of the textfield
			txt.width  = width;
			txt.height = height;

			// save size
			txt_width  = width;
			txt_height = height;

			// update background shape
			updateSTYLE();
		}



		private function link_event(textevent:TextEvent):void
		{
			// pass the text after the "event:" link to krpano

			krpano.call( textevent.text, null, pluginobj );
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

			txt.wordWrap   = pluginobj.wordwrap;
			txt.selectable = pluginobj.selectable;

			// update/draw the background shape
			bg.alpha = pluginobj.backgroundalpha;

			bg.graphics.clear();

			// draw a background and/or border?
			if (pluginobj.background || pluginobj.border)
			{
				if (pluginobj.borderwidth > 0)
					bg.graphics.lineStyle(pluginobj.borderwidth, pluginobj.bordercolor);

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
				filters.push( new GlowFilter(pluginobj.glowcolor, 1.0, pluginobj.glow,pluginobj.glow) );
			}

			if (pluginobj.blur > 0)
			{
				// blur = blur range
				filters.push( new BlurFilter(pluginobj.blur, pluginobj.blur) );
			}

			if (pluginobj.shadow > 0)
			{
				// shadow = shadow range
				filters.push( new DropShadowFilter(pluginobj.shadow) );
			}

			// set or remove the filters
			bg.filters = filters.length > 0 ? filters : null


			// create and apply filters for the text itself
			var textfilters:Array = new Array();

			if (pluginobj.textglow > 0)
			{
				// textglow = glowing range
				// textglowcolor = color of the glowing
				textfilters.push( new GlowFilter(pluginobj.textglowcolor, 1.0, pluginobj.textglow,pluginobj.textglow) );
			}

			if (pluginobj.textblur > 0)
			{
				// textblur = blur range
				textfilters.push( new BlurFilter(pluginobj.textblur,  pluginobj.textblur) );
			}

			if (pluginobj.textshadow > 0)
			{
				// textshadow = shadow range
				textfilters.push( new DropShadowFilter(pluginobj.textshadow) );
			}

			// set or remove the filters
			txt.filters = textfilters.length > 0 ? textfilters : null
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
				txt.styleSheet = css;
			}

			if (htmldata.indexOf("data:") == 0 )
			{
				// load the content of a <data> tag
				htmldata = krpano.get("data[" + htmldata.slice(5) + "].content");
			}
			else
			{
				// directly use the given html
				// (<> chars are not possible in a xml attribure, therefore provide the usage of [] instead)

				// replace '[' -> '<'
				htmldata = str_replace(htmldata,"[","<");

				// replace ']' -> '>'
				htmldata = str_replace(htmldata,"]",">");

				htmldata = unescape(htmldata);
			}

			if (htmldata == null)
			{
				htmldata = "";
			}


			txt.htmlText = htmldata;


			if (txt.autoSize != "none")
			{
				// the as3 textfield autosizing is used

				// save size
				txt_height = txt.height;

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

			//krpano.set(pluginpath + ".height",     txt_height);
			//krpano.set(pluginpath + ".textheight", txt.textHeight);
			// update the real textfield and text sizes in krpano
			pluginobj.height     = txt_height;
			pluginobj.textheight = txt.textHeight;

			// update the background shape
			updateSTYLE();
		}
	}
}
