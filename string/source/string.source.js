/*
string plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/string/plugin.html
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
			krpano.trace(3,"string plugin - too old krpano version (min. 1.0.8.14)");
			return;
		}

		// register methods
		plugin.txtlength  = txtlength;
		plugin.txtchunk = txtchunk;
		plugin.txtfind  = txtfind;
		plugin.txtreplace = txtreplace;
		plugin.txttrim = txttrim;
		plugin.txtlower = txtlowercase;
		plugin.txtupper = txtuppercase;
	}
		
		
	local.unloadplugin = function()
	{
		plugin = null;
		krpano = null;
	}
	
	
	////////////////////////////////////////////////////////////
	// public methods
	
	function txtlength(varName, subject)
	{
		// return the length of the supplied text
		krpano.set(varName, subject.length);
	}
	
	function txtchunk(varName, subject, start, length)
	{
		// return a substring of the supplied text
		krpano.set(varName, subject.substr(start, length));
	}
	
	function txtfind(varName, subject, find)
	{
		// find a needle in a haystack and return its position
		krpano.set(varName, subject.indexOf(find));
	}
	
	function txtreplace(varName, subject, find, replace, flags)
	{
		// find and replace a needle in a haystack
		var pattern = new RegExp(find, flags);
		krpano.set(varName, subject.replace(pattern, replace) );
	}
	
	function txttrim(varName, subject)
	{
		// trim leading and trailing whitespace
		var pattern = new RegExp(find, flags);
		krpano.set(varName, ((subject!=undefined)?subject:krpano.get(varName)).replace(pattern, "") );
	}
	
	function txtlowercase(varName, subject)
	{
		// make subject lowercase
		krpano.set(varName, ((subject!=undefined)?subject:krpano.get(varName)).toLowerCase() );
	}
	
	function txtuppercase(varName, subject)
	{
		// make subject lowercase
		krpano.set(varName, ((subject!=undefined)?subject:krpano.get(varName)).toUpperCase() );
	}
}