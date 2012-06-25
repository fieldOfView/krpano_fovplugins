krpano gyroscope plugin for krpanoJS
====================================
by [Aldo Hoeben / fieldOfView](http://fieldofview.com/) 
contributions by 
	[Sjeiti](http://ronvalstar.nl/) 
	[Klaus](http://krpano.com/)
	
This plugin uses the gyroscope in iOS devices such as the 
iPhone 4 and iPod Touch 4th generation to control the view in
krpanoJS.

How to use
----------

The gyro.js file is included as a plugin in the krpano xml file:
<plugin url="gyro.js" enabled="true" friction="0.5" camroll="true" velastic="0.25" vrelative="false" />

The source of the plugin is compressed using Google Closure Compiler. You may use either the compressed or the source version.

NOTE: including the gyro.js directly in your html page is no longer supported. 

License
-------

This software can be used free of charge and the source code is available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.