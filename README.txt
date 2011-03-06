fieldOfView krpano plugins
================================================================

A series of krpano plugins by Aldo Hoeben / fieldOfView
http://fieldofview.com/

autolevels 
----------
A plugin that dynamically applies an autolevels effect to the 
krpano view. When properly used, this can mimic autoexposure of 
a (video-)camera, or the adaptation of the human perceptive 
system. 

clipboard
---------
A plugin that provides write-only access to the clipboard. This
is useful eg to put a link to the current view into the viewer's
clipboard.

dblclick
--------
A plugin that adds a doubleclick event to krpano. 

vectormath
----------
A utility plugin that adds vector-math calculations to krpano.

string
------
A utility plugin that adds string manipulation functions to 
krpano. 



License
-------

The plugins can be used free of charge and the source code is 
available under a CC-GNU GPL license.
http://creativecommons.org/licenses/GPL/2.0/


How to build
------------

To build the plugins from the supplied source files, you need 
the open source Flex SDK, version 3.2 or newer, from Adobe:
http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK

To compile a swf, use the following commandline options (in a
single line):
mxmlc -target-player=10.0.0 -use-network=false 
 -static-link-runtime-shared-libraries=true [filename].as