krpano misc plugin
=======================

A krpano plugin that provides some miscelaneous scripting
functionalities that do not fit in with any of the other plugins 
in the package.
  
* `for(varName, startValue, endValue, stepValue, iterate)`  
	Iterates the actions/function specified by 'iterate' while setting the variable 'varName' from 'startValue' 
	until it reaches 'endValue' in steps set by 'stepValue'.  
* `abs(destVar, value)`  
	Sets destVar to the absolute value of 'value'. If the second argument is omitted, the method alters the current contents of destVar instead. 
* `max(destVar, value1, value2, ...)`  
	Sets destVar to the highest of the passed values.
* `min(destVar, value1, value2, ...)`  
	Sets destVar to the lowest of the passed values.
	

How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile misc.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true misc.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

