krpano gyroscope script for iOS 4.2 
by Aldo Hoeben / fieldofview.com
contributions by Sjeiti / ronvalstar.nl

Tested for krpano 1.0.8.12 (build 2010-11-24) and iPhone4

Include krpanoGyro.js in the head of your html document or near swfkrpano.js

The simplest way to use the script is to keep the script as is and use the default name for the krpano embed object
[code]
var swf = createswf("krpano.swf");
swf.addVariable("xml","panorama.xml");
swf.embed("krpanoDIV");
[/code]

If you use a different object ID to embed your krpano, or want more control over the gyro script, use the following method instead.

Call the krpanoGyro function after you've created the pano and parse the krpano object that createPanoViewer returns.
Best place for the following code would be in an onLoad or an onDomReady.

[code]
krpano = createPanoViewer({swf:"krpano.swf", xml:"panorama.xml", target:'myHtmlElementId'});
if (krpano.isHTML5possible()) {
	krpano.useHTML5("always");
	krpano.embed();
	gyro = krpanoGyro(krpano);
	//gyro.disable();
}
[/code]

The gyro object contains the following functions:

gyro.enable();
gyro.disable(); 
gyro.toggle();
gyro.deviceAvailable();
gyro.setAdaptiveV();
gyro.adaptiveV();

The script also creates an object named "gyro" in krpano which can be used to enable/disable the gyro.
The following creates a button to toggle the gyroscope that is only visible when the gyro device is detected, and enables the adaptive vertical offset.
[code]
<krpano ... onstart="initgyro()">
	...
	<plugin name="gyrotoggle" visible="false" ... onclick="gyro.toggle();" />
	<action name="initgyro"> 
		copy(plugin[gyrotoggle].visible, gyro.deviceAvailable);
		gyro.setAdaptiveV(true);
	</action>
[/code]

The gyro object in krpano mirrors the functionality of the javascript object, but enabled, deviceAvailable and adaptiveV are read-only properties instead of functioncalls. 

This software is licensed under the CC-GNU GPL version 2.0 or later
http://creativecommons.org/licenses/GPL/2.0/