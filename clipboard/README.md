krpano clipboard plugin
=======================

A krpano plugin that provides a way to copy text into the system 
clipboard. Access to the clipboard is write-only, so you can not 
paste into the krpano viewer. The clipboard plugin has one 
attribute which can be set through krpano actions.
  
* `text`  
	Text to copy to the system clipboard.  
	

How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile clipboard.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true clipboard.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

