krpano gyroscope script for iOS 4.2 
===================================
by [Aldo Hoeben / fieldOfView](http://fieldofview.com/) 
contributions by [Sjeiti](http://ronvalstar.nl/) 

This script uses the gyroscope in iOS devices such as the 
iPhone 4 and iPod Touch 4th generation to control the camera in
krpanoJS.

How to use
----------

Include krpanoGyro.js in the head of your html document or near 
swfkrpano.js

The simplest way to use the script is to keep the script as is 
and use the default name for the krpano embed object
	var swf = createswf("krpano.swf");
	swf.addVariable("xml","panorama.xml");
	swf.embed("krpanoDIV");

If you use a different object ID to embed your krpano, or want 
more control over the gyro script, use the following method 
instead.

Call the krpanoGyro function after you've created the pano and 
parse the krpano object that createPanoViewer returns.
Best place for the following code would be in an onLoad or an 
onDomReady.

	krpano = createPanoViewer({swf:"krpano.swf", xml:"panorama.xml", target:'myHtmlElementId'});
	if (krpano.isHTML5possible()) {
		krpano.useHTML5("always");
		krpano.embed();
		krpanoGyro(krpano);
	}

The script creates an object named "gyro" in krpano which can be used to enable/disable the gyro. 
This object has the following properties:
	gyro.deviceavailable 
		Used to determine if the gyro device is available 
		true/false, read-only
	gyro.enabled;
		Enable or disable gyroscopic navigation 
		true/false, default: true
	gyro.easing;
		Dampen gyroscopic navigation. '0' means no dampening (twitchy behavior), 1 means infinite dampening (ie: no gyroscopic behavior)
		0-1, default: 0.5
	gyro.adaptivev;
		Determine whether the view returns to the pitch value of the device after manually swiping
		true/false, default: false
You can access these properties through scripting, and/or you can set them in your xml (see example below)

For convenience and backwards compatibility, the object also has the following methods:
	gyro.enable()
	gyro.disable() 
	gyro.toggle()
		Set krpano.enabled 
	gyro.setadaptivev();
		Set krpano.adaptivev

The following creates a button to toggle the gyroscope that is only visible when the gyro device is detected, and enables the adaptive vertical offset.
	<krpano ... onstart="initgyro()">
		...
		<gyro easing="0.1" adaptivev="true" />
		<plugin name="gyrotoggle" visible="false" ... onclick="gyro.toggle();" />
		<action name="initgyro"> 
			copy(plugin[gyrotoggle].visible, gyro.deviceAvailable);
		</action>
		...

License
-------

This software can be used free of charge and the source code is available under a [Creative Commons Attribution](http://creativecommons.org/licenses/by/3.0/) license.