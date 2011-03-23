krpano dblclick plugin
======================

A krpano plugin that provides a way to respond to doubleclick events.
The plugin has a single attribute: 
  
* `ondblclick`  
	Actions / functions that will be called when there is a doubleclick on the krpano viewer.  
	

How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile dblclick.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true dblclick.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

