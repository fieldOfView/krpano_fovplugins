fieldOfView krpano plugins
==========================

A series of krpano plugins by [Aldo Hoeben / fieldOfView](http://fieldofview.com/)

* **autolevels**  
	A plugin that dynamically applies an autolevels effect to the 
	krpano view. When properly used, this can mimic autoexposure of 
	a (video-)camera, or the adaptation of the human perceptive 
	system. 

* **clipboard**  
	A plugin that provides write-only access to the clipboard. This 
	is useful eg to put a link to the current view into the viewer's 
	clipboard.

* **dblclick**  
	A plugin that adds a doubleclick event to krpano. 

* **gyro**  
	A plugin that uses the gyroscope in devices such as the iPhone 4 
	and iPad2 to control the view.
	
* **imageadjust**
	A plugin that lets you adjust the brightness/contrast, hue/saturation
	and blur of the view.

* **misc**
	A plugin that adds miscelaneous functionalities to krpano which do 
	not fit in with any of the other plugins in the package.
	
* **multitouch**
	A plugin that enables multitouch zoom on Windows 7 and Android
	multitouch devices.
	
* **orientation**
	A plugin that detects changes in the device orientation.
	
* **string**  
	A plugin that adds string manipulation functions to krpano. 
	
* **textfieldex**
	A drop-in replacement for the textfield.swf krpano plugin with 
	extended capabilities.

* **vectormath**  
	A plugin that adds vector-math calculations to krpano.

Examples
--------
The plugins folders contain examples which demonstrate the use of 
each plugin. For the examples to work out of the box, the
fovplugins package expects to be located inside the krpano folder 
(ie at the same level as the plugins folder). 


How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile a swf, use the following commandline options (in a 
single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true [filename].as
	
Javascript plugins are compressed using the Google Closure Compiler. 
Alternatively you may use the source-version instead of the compressed 
version.
 
 
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

 