/*
orientation plugin for KRPanoJS and iOS4.2+
by Aldo Hoeben / fieldOfView.com
	
http://fieldofview.github.com/krpano_fovplugins/orientation/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin = function()
{
	var local = this,
		krpano = null, plugin = null,
	
		onOrientationChange = "",
		orientation = (top.orientation === undefined)?0:top.orientation,
		landscape = (Math.abs(orientation) == 90),
		portrait = !landscape;

	////////////////////////////////////////////////////////////
	// plugin management
	
	local.registerplugin = function(krpanointerface, pluginpath, pluginobject)
	{
		krpano = krpanointerface;
		plugin = pluginobject;
		
		if (krpano.version < "1.0.8.14" || krpano.build < "2011-03-30")
		{
			krpano.trace(3,"orientation plugin - too old krpano version (min. 1.0.8.14)");
			return;
		}

		top.addEventListener("orientationchange", handleOrientationChange, true);
		
		// register attributes
		plugin.registerattribute("orientation",        orientation, function(arg){}, function(){ return orientation; });
		plugin.registerattribute("landscape",          landscape,   function(arg){}, function(){ return landscape; });
		plugin.registerattribute("portrait",           portrait,    function(arg){}, function(){ return portrait; });
		plugin.registerattribute("onorientationchange",onOrientationChange, function(arg){ onOrientationChange = arg }, function(){ return onOrientationChange; });
	}
		
		
	local.unloadplugin = function()
	{
		top.removeEventListener("orientationchange", handleOrientationChange);

		plugin = null;
		krpano = null;
	}
	
	
	////////////////////////////////////////////////////////////
	// public methods
		
	////////////////////////////////////////////////////////////
	// private methods	
	
	function handleOrientationChange(event)
	{
		orientation = top.orientation;
		landscape = (Math.abs(orientation) == 90),
		portrait = !landscape;
		
		krpano.call( onOrientationChange );		
	}
}