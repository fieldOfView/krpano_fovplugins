/*
misc plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/misc/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin = function()
{
	var local = this,
		krpano = null, plugin = null;

	////////////////////////////////////////////////////////////
	// plugin management
	
	local.registerplugin = function(krpanointerface, pluginpath, pluginobject)
	{
		krpano = krpanointerface;
		plugin = pluginobject;
		
		if (krpano.version < "1.0.8.14" || krpano.build < "2011-03-30")
		{
			krpano.trace(3,"misc plugin - too old krpano version (min. 1.0.8.14)");
			return;
		}

		// register methods
		plugin.forloop = interface_for;
		plugin.abs = interface_abs;
		plugin.min = interface_min;
		plugin.max = interface_max;		
	}
		
		
	local.unloadplugin = function()
	{
		plugin = null;
		krpano = null;
	}
	
	
	////////////////////////////////////////////////////////////
	// public methods
	
	function interface_abs(varName, value)
	{
		// return the absolute value of the supplied value
		krpano.set(varName, Math.abs( ((value!=undefined)?value:this.krpano.get(varName)) ));
	}
	
	function interface_for(varName, startValue, endValue, stepValue, iterate)
	{
		// for-loop
		startValue = parseFloat(startValue);
		endValue = parseFloat(endValue);
		stepValue = parseFloat(stepValue);
		
		if(iterate == "" || stepValue==0)
			return;
			
		var value = startValue;
		krpano.set(varName, value);
		
		while( (stepValue > 0 && value <= endValue) || (stepValue < 0 && value >= endValue) ) {
			krpano.call(iterate);
			value += stepValue;
			krpano.set(varName, value);
		}
		
		krpano.set(varName, endValue);
	}
	
	function interface_max(varName)
	{
		// largest value
		if(arguments.length > 1) {
			value = arguments[1];
			for(var i=2; i<arguments.length; i++) {
				value = Math.max(value, arguments[i]);
			}
		}
		this.krpano.set(varName, value );
	}		
	
	function interface_min(varName) 
	{
		// smallest value
		if(arguments.length > 1) {
			value = arguments[1];
			for(var i=2; i<arguments.length; i++) {
				value = Math.min(value, arguments[i]);
			}
		}
		this.krpano.set(varName, value );
	}	
}