/*
	krpano iOS 4.2 gyroscope script
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
*/

if (!this.krpanoGyro) {
	var krpanoGyro = function(krpanoObjectOrName) {
		var isDeviceEnabled = !!window.DeviceOrientationEvent,
			krpano,
			objectname,
			
			o = {
				 enable:						enable
				,disable:						disable
				,toggle:						toggle
				,deviceAvailable: function() {	return isDeviceEnabled; }
				,deviceavailable:				false
				,enabled: function() {			return isEnabled; }
				,setAdaptiveV: 					setAdaptiveVOffset
				,setadaptivev: 					setAdaptiveVOffset
				,adaptiveV: function() {		return isAdaptiveVOffset; }
				,adaptivev:						false
				,toString: function() {			return "[object krpanoGyro]"; }
			}, // note: krpano converts calls/methodnames to lowercase
			
			isEnabled = false,
			isAdaptiveVOffset = false,
			isTouching = false,
			
			hoffset = 0, voffset = 0,
			hlookat = 0, vlookat = 0,
			
			degRad = Math.PI/180;
			
		if( krpanoObjectOrName )
			objectname = ( typeof( krpanoObjectOrName )=='object' ) ? krpanoObjectOrName.pid : krpanoObjectOrName;
		else
			objectname = 'krpanoSWFObject';
		
		////////////////////////////////////////////////////////////

		if (isDeviceEnabled) waitForElement();		

		////////////////////////////////////////////////////////////

		function waitForElement() {
			krpano = document.getElementById(objectname);
			if (krpano && krpano.get != undefined)	startGyro();
			else		setTimeout(waitForElement,100);
		}

		function startGyro() {
			// get offsets for defaultview
			hoffset = krpano.get("view.hlookat");
			voffset = krpano.get("view.vlookat");
			krpano.set("gyro", o);
			krpano.set("gyro.deviceavailable", true);
			krpano.set("gyro.adaptivev", isAdaptiveVOffset);
			krpano.set("gyro.enabled", isEnabled);

			enable();			
		}

		////////////////////////////////////////////////////////////
		
		function enable() {
			if (isDeviceEnabled && !isEnabled) {
				window.addEventListener("deviceorientation", handleDeviceOrientation, true);
				krpano.addEventListener("touchstart", handleTouchStart, true);
				krpano.addEventListener("touchend", handleTouchEnd, true);		
				krpano.addEventListener("touchcancel", handleTouchEnd, true);	
				isEnabled = true;
				if(krpano)
					krpano.set("gyro.enabled", true);
			}
			return isEnabled;
		}

		function disable() {
			if (isDeviceEnabled && isEnabled) {
				window.removeEventListener("deviceorientation", handleDeviceOrientation);
				krpano.removeEventListener("touchstart", handleTouchStart);
				krpano.removeEventListener("touchend", handleTouchEnd);		
				krpano.removeEventListener("touchcancel", handleTouchEnd);	
				isEnabled = false;
				if(krpano)
					krpano.set("gyro.enabled", false);
			}
			return isEnabled;
		}
		
		function toggle() {
			if(isEnabled)
				return disable();
			else
				return enable();
		}
		
		function setAdaptiveVOffset(arg) {
			switch(arg) {
				case 0, "0", false, "false":
					isAdaptiveVOffset = false;
					break;
				case 1, "1", true, "true":
					isAdaptiveVOffset = true;
					break;
				default:
					isAdaptiveVOffset = !isAdaptiveVOffset;
					break;
			}
			if (krpano && krpano.set != undefined)
				krpano.set("gyro.adaptivev", isAdaptiveVOffset);
		}

		////////////////////////////////////////////////////////////
		
		function handleTouchStart(event) {
			isTouching = true;
		}

		function handleTouchEnd(event) {
			isTouching = false;	
		}
		
		function handleDeviceOrientation(event) {
			if ( !isTouching && isEnabled ) {

				// process event.alpha, event.beta and event.gamma
				var orientation = rotateEuler( new Object( { 
						yaw: event["alpha"] * degRad, 
						pitch: event["beta"] * degRad, 
						roll: event["gamma"] * degRad 
					} ) ),
					yaw = orientation.yaw / degRad,
					pitch = orientation.pitch / degRad,
					altyaw = yaw,
					factor;

				// fix gimbal lock
				if( Math.abs(pitch) > 70 ) {
					altyaw = event.alpha; 
					
					switch(window.orientation) {
						case 0:
							if ( pitch>0 ) 
								altyaw += 180;
							break;
						case 90: 
							altyaw += 90;
							break;
						case -90: 
							altyaw += -90;
							break;
					}
					
					altyaw = altyaw % 360;
					if( Math.abs( altyaw - yaw ) > 180 ) 
						altyaw += ( altyaw < yaw ) ? 360 : -360;
					
					factor = Math.min( 1, ( Math.abs( pitch ) - 70 ) / 10 );
					yaw = yaw * ( 1-factor ) + altyaw * factor;
				}

				// track view change since last orientation event
				// -> user has manually panned, or krpano has altered lookat
				hoffset += krpano.get("view.hlookat") - hlookat;
				voffset += krpano.get("view.vlookat") - vlookat;
				
				// clamp voffset
				if(Math.abs( pitch + voffset ) > 90) {
					voffset = ( pitch+voffset > 0 ) ? (90 - pitch) : (-90 - pitch)
				}
				
				hlookat = (-yaw -180 + hoffset ) % 360;
				vlookat = Math.max(Math.min(( pitch + voffset ),90),-90);
				
				krpano.call( "lookat(" + hlookat + "," + vlookat + ")" );
				
				adaptVOffset();
			}
		}

		function adaptVOffset() {
			if( voffset != 0 && isAdaptiveVOffset ) {
					voffset *= 0.98;
					if( Math.abs( voffset ) < 0.1 ) {
						voffset = 0;
					}
			}
		}

		function rotateEuler( euler ) {
			// based on http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToMatrix/index.htm
			// and http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToEuler/index.htm

			var heading, bank, attitude,
				ch = Math.cos(euler.yaw),
				sh = Math.sin(euler.yaw),
				ca = Math.cos(euler.pitch),
				sa = Math.sin(euler.pitch),
				cb = Math.cos(euler.roll),
				sb = Math.sin(euler.roll);

			// note: includes 90 degree rotation around z axis
			matrix = new Array( 
				sh*sb - ch*sa*cb,   -ch*ca,    ch*sa*sb + sh*cb,
				ca*cb,              -sa,      -ca*sb,			
				sh*sa*cb + ch*sb,    sh*ca,   -sh*sa*sb + ch*cb
			);
						
			/* [m00 m01 m02] 0 1 2
			 * [m10 m11 m12] 3 4 5 
			 * [m20 m21 m22] 6 7 8 */
			 
			if (matrix[3] > 0.9999) { // singularity at north pole
				heading = Math.atan2(matrix[2],matrix[8]);
				attitude = Math.PI/2;
				bank = 0;
			} else if (matrix[3] < -0.9999) { // singularity at south pole
				heading = Math.atan2(matrix[2],matrix[8]);
				attitude = -Math.PI/2;
				bank = 0;
			} else {
				heading = Math.atan2(-matrix[6],matrix[0]);
				bank = Math.atan2(-matrix[5],matrix[4]);
				attitude = Math.asin(matrix[3]);
			}
			
			return new Object( { yaw:heading, pitch:attitude, roll:bank } ) 
		}
		
		///////////////////////////////////////////////////
		
		return o;
	};
}

// Comment out or edit the following line if you want to use a custom krpano object or a different object name
var gyro = krpanoGyro();
