krpano imageadjust plugin
=========================

A krpano plugin that lets you set the brightness/contrast, as 
well as hue/saturation and blur of the krpano view. 

The following parameter are available:

* `enabled` (true/false)  
    enable/disable all adjustments
* `brightness` (-1 to 1)  
    overall brightness
* `contrast` (-1 to 1)  
    overall contrast
* `hue` (-180 to 180)  
    hue adjustment
* `saturation` (-1 to 1)  
    overall saturation
* `blurradius` (>=0)  
    blurring of the krpano display 

The parameters can also be set all at once with a single utility method:

* `adjust(brightness, contrast, hue, saturation, blurradius)`  
	sets each of the respective properties in one go



How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile autolevels.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true imageadjust.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

