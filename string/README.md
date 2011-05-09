krpano string plugin
====================

A krpano plugin that provides a number of string manipulation methods: 
  
* `txtlength(destVar, text)`  
	Sets destVar to the length of 'text'  
* `txtchunk(destVar, text, start, length)`  
	Sets destVar to the substring of 'text', starting from 'start' and 'length' characters long  
* `txtfind(destVar, text, find)`  
	Sets destVar to the position of 'find' in 'text', or -1 if the text is not found  
* `txtreplace(destVar, text, find, replace, flags)`  
	Sets destVar to a copy of 'text', replacing 'find' with 'replace'. The optional 'flags' argument can be used to set flags for the internal regular expression pattern (and defaults to ''gi' for a global, case-insensitive replace).
* `txttrim(destVar, text)`  
	Sets destVar to 'text' without leading and trailing whitespace. If the second argument is omitted, the method alters the current contents of destVar instead.
* `txtupper(destVar, text)`  
	Sets destVar to an uppercase version of 'text'. If the second argument is omitted, the method alters the current contents of destVar instead.
* `txtlower(destVar, text)`  
	Sets destVar to a lowercase version of 'text'. If the second argument is omitted, the method alters the current contents of destVar instead.
	
These methods are meant to complement the builtin txtadd method to concatenate strings. Note that all parameters except destVar are taken as literals. If you want to pass the value of a variable or property, you have to use the get() function.
	

How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile string.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true string.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.

