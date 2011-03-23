krpano autolevels plugin
========================

A krpano plugin that dynamically applies an autolevels effect to 
the krpano view. 

When properly used, this can mimic autoexposure of a (video-)
camera, or the adaptation of the human perceptive system. The 
effect can be tuned to affect just the luminosity of the view, 
or the luminosity as well as the color of the view. 

Please note that the effect is applied to the (jpeg compressed) 
8 bit panorama, so if the effect is too pronounced you will 
start to see artifacts such as banding and color mismatches. 
There is a number of parameters that will let you tone down the 
effect to suite your images:

* `enabled` (true/false)  
    enable/disable the "metering"
* `effect` (0-1)  
    limit the effect of the plugin (0: no effect, 1: full effect)
* `adaptation` (0-1)  
    speed at which the camera iris "adapts" (1: full speed, less means there is a transition)
* `coloradjust` (0-1)  
    amount of color adjusting to do (0: only lightness, 1: lightness and color)
* `threshold` (0-255)  
    clip small highlight and/or shadow areas
* `attenuation` (0-1)  
    "centerweight": 0: meter full view/window, 1: only use center pixel of the window for metering 


How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile autolevels.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true autolevels.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

