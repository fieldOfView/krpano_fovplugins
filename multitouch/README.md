krpano multitouch zoom plugin
=============================

A krpano plugin that enables multitouch zoom on Windows 7 and Android multitouch devices.
On Android devices, the plugin only works inside AIR applications; the Android browser is not supported at this time.
The plugin has no attributes 
  

How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile dblclick.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.1.0 -use-network=false -static-link-runtime-shared-libraries=true multitouch.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

