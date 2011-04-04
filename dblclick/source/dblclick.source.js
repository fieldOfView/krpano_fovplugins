/*
dblclick plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/dblclick/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin = function()
{
	var local = this,
		krpano = null, plugin = null,
	
		onDblClick;
	

	////////////////////////////////////////////////////////////
	// plugin management
	
	local.registerplugin = function(krpanointerface, pluginpath, pluginobject)
	{
		krpano = krpanointerface;
		plugin = pluginobject;
		
		if (krpano.version < "1.0.8.14" || krpano.build < "2011-03-30")
		{
			krpano.trace(3,"dblclick plugin - too old krpano version (min. 1.0.8.14)");
			return;
		}

		// register attributes
		plugin.registerattribute("ondblclick","", function(arg){ onDblClick = arg }, function(){ return onDblClick; });		
		
		// register eventlistener
		krpano.control.layer.addEventListener("dblclick",  handleDblClick, true);
	}
		
		
	local.unloadplugin = function()
	{
		krpano.control.layer.removeEventListener("dblclick",  handleDblClick);
		
		plugin = null;
		krpano = null;
	}
	
	
	////////////////////////////////////////////////////////////
	// public methods
	
		
	////////////////////////////////////////////////////////////
	// private methods	
	
	function handleDblClick(event)
	{
		krpano.call( onDblClick );
	}
}