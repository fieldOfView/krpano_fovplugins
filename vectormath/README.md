krpano vectormath plugin
========================

A krpano plugin that provides a number of vector math methods: 

* `sin(destVar, angle)`  
	Sets destVar to the sine of 'angle'
* `cos(destVar, angle)`  
	Sets destVar to the cosine of 'angle'
* `tan(destVar, angle)`  
	Sets destVar to the tangens of 'angle'
* `asin(destVar, number)`  
	Sets destVar to the inverse sine of 'number'
* `acos(destVar, number)`  
	Sets destVar to the inverse cosine of 'number'
* `atan(destVar, number)`  
	Sets destVar to the inverse tangent of 'number'
* `atan2(destVar, opposite, adjacent)`  
	Sets destVar to the inverse tangent of 'opposite'/'adjacent'
* `anglebetween(destVar, ath1, atv1, ath2, atv2)`  
	Sets destVar to the angle between the two vectors defined by ('ath1', 'atv1') and ('ath2', 'atv2')
* `normal(destVarH, destVarV, ath1, atv1, ath2, atv2)`  
	Sets destVarH and destVarV to align with the normal of the two vectors defined by ('ath1', 'atv1') and ('ath2', 'atv2')
* `rotatevector(destVarH, destVarV, destVarRotate, ath1, atv1, rotate1, ath2, atv2, rotate2)`  
	Sets destVarH, destVarV and destVarRotate to align with the vector ('ath1', 'atv1', 'rotate1') after it has been rotated by ('ath2', 'atv2', 'rotate2')
	
All angles are specified and returned in degrees, and axis rotations are done in the same order as krpano does them. 
	

How to build
------------

To build the plugins from the supplied source files, you need the 
[open source Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK), version 3.2 or newer.

To compile vectormath.swf, use the following commandline options
(in a single line):
	mxmlc -target-player=10.0.0 -use-network=false -static-link-runtime-shared-libraries=true vectormath.as

	
License
-------

The plugins can be used free of charge and the source code is 
available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.
