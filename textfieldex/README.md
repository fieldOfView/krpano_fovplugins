krpano string plugin
====================

A drop-in replacement for the textfield.swf krpano plugin with 
extended capabilities. It is based on the textfield.swf sources 
distributed with the krpano viewer package, and inherits all of 
its functionality. The documentation for the original textfield 
plugin can be found here:
krpano.com/plugins/textfield

The textfieldex version of the plugin adds the following properties:

* `text`  
	Set/read pure text, without HTML tags
* `scaletext` (true/false)  
	Scale text/fontsize with plugin/hotspot
* `autosizemargin` (>=0)  
	Adds a margin to the bottom of the background when autosize="true"
* `autowidth` (true/false)  
	Automatically adjust the width of the background (when multiline="false")
* `autowidthmargin` (>=0)  
	Adds a margin to the right of the background when autowidth="true"
* `multiline` (true/false)  
	Determine if all text should be rendered on a single line	
* `editable` (true/false)  
	Makes the textfield editable
* `password` (true/false)  
	Hides the typed characters
* `onsubmit`  
	Actions / function that will be called when the user presses enter in an editable, non-multiline textfield.
* `quality` (normal/high)  
	Enhanced render quality for fonts
* `borderalpha` (0-1)  
	Set the alpha of the border
* `borderjoints` (miter/round/bevel)  
	Set the shape of the joints of the border	
* `glowalpha` (0-1)  
	Set the alpha of the rendered glow around the plugin/hotspot
* `shadowangle` (0-360)  
	Set the angle of the rendered shadow around the plugin/hotspot
* `shadowcolor`  
	Set the color of the rendered shadow around the plugin/hotspot
* `shadowalpha` (0-1)  
	Set the alpha of the rendered shadow around the plugin/hotspot
* `shadowblur` (>=0)  
	Set the blur amount of the rendered shadow around the plugin/hotspot
* `textglowalpha`  (0-1)  
	Set the alpha of the rendered glow around the text
* `textshadowangle` (0-360)  
	Set the angle of the rendered shadow around the text
* `textshadowcolor`  
	Set the color of the rendered shadow around the text
* `textshadowalpha` (0-1)  
	Set the alpha of the rendered shadow around the text
* `textshadowblur` (>=0)  
	Set the blur amount of the rendered shadow around the text
	
You may rename the plugin to textfield.swf and use it instead of 
the stock version, but note that this functionality is not available 
for the builtin textfield of the HTML5 viewer.
	

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

