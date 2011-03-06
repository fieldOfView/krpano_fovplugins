krpano autolevels plugin
================================================================

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
effect to suite your images.

License
-------

The plugin can be used free of charge and its source code is 
available under a CC-GNU GPL license.
http://creativecommons.org/licenses/GPL/2.0/


How to build
------------

To build the autolevels.swf file, you need the open source Flex 
SDK, version 3.2 or newer, from Adobe:
http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK

To compile autolevels.swf, use the following commandline options:
mxmlc -target-player=10.0.0 -use-network=false autolevels.as