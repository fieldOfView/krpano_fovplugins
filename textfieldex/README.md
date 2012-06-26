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
* `scaletext`
	Scale text/fontsize with plugin/hotspot
* `autosizemargin`
	Adds a margin to the bottom of the background when autosize="true"
* `autowidth`
	Automatically adjust the width of the background (when multiline="false")
* `autowidthmargin`
	Adds a margin to the right of the background when autowidth="true"
* `multiline`
	Determine if all text should be rendered on a single line	
* `editable`
	Makes the textfield editable
* `password`
	Hides the typed characters
* `onsubmit`
	Actions / function that will be called when the user presses enter in an editable, non-multiline textfield.
* `quality`
	Enhanced render quality for fonts
* `borderalpha`
	Set the alpha of the border
* `borderjoints`
	Set the shape of the joints of the border	
* `glowalpha`
	Set the alpha of the rendered glow around the plugin/hotspot
* `shadowangle`
	Set the angle of the rendered shadow around the plugin/hotspot
* `shadowcolor`
	Set the color of the rendered shadow around the plugin/hotspot
* `shadowalpha`
	Set the alpha of the rendered shadow around the plugin/hotspot
* `shadowblur`
	Set the blur amount of the rendered shadow around the plugin/hotspot
* `textglowalpha
	Set the alpha of the rendered glow around the text
* `textshadowangle`
	Set the angle of the rendered shadow around the text
* `textshadowcolor`
	Set the color of the rendered shadow around the text
* `textshadowalpha`
	Set the alpha of the rendered shadow around the text
* `textshadowblur`
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

