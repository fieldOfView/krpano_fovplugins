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
		krpanoGyro(krpano);
	}
	[/code]


	The script creates an object named "gyro" in krpano which can be used to enable/disable the gyro. 
	This object has the following properties:
	[code]
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
	[/code]
	You can access these properties through scripting, and/or you can set them in your xml (see example below)
	
	For convenience and backwards compatibility, the object also has the following methods:
	[code]
		gyro.enable()
		gyro.disable() 
		gyro.toggle()
			Set krpano.enabled 
		gyro.setadaptivev();
			Set krpano.adaptivev
	[/code]
	
	The following creates a button to toggle the gyroscope that is only visible when the gyro device is detected, and enables the adaptive vertical offset.
	[code]
	<krpano ... onstart="initgyro()">
		...
		<gyro easing="0.1" adaptivev="true" />
		<plugin name="gyrotoggle" visible="false" ... onclick="gyro.toggle();" />
		<action name="initgyro"> 
			copy(plugin[gyrotoggle].visible, gyro.deviceAvailable);
		</action>
	[/code]
	
	This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/

*/

if (!this.krpanoGyro) {
	var krpanoGyro = function(krpanoObjectOrName) {
		var isDeviceEnabled = !!window.DeviceOrientationEvent,
			krpano,
			objectname,
			
			isEnabled = false,
			isAdaptiveVOffset = false,
			isEasing = 0.5;

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
			var gyroobject = {
				 deviceavailable:				true
				,enabled:						isEnabled
				,enable:						enable
				,disable:						disable
				,toggle:						toggle
				,easing:						isEasing
				,adaptivev: 					isAdaptiveVOffset
				,setadaptivev: 					setAdaptiveVOffset
			}
			gyroobject.__defineSetter__("enabled", function (arg) {
				if(Boolean(arg))
					enable();
				else
					disable();
			});
			gyroobject.__defineGetter__("enabled", function (arg) {
				return isEnabled;
			});	

			gyroobject.__defineSetter__("adaptivev", function (arg) {
				setAdaptiveVOffset(arg)
			});
			gyroobject.__defineGetter__("adaptivev", function (arg) {
				return isAdaptiveVOffset;
			});			
			
			gyroobject.__defineSetter__("easing", function (arg) {
				isEasing = Math.max(Math.min(arg, 1), 0);
			});
			gyroobject.__defineGetter__("easing", function (arg) {
				return isEasing;
			});
			
			krpano.set("gyro", gyroobject);
			
			// get offsets for defaultview
			hoffset = krpano.get("view.hlookat");
			voffset = krpano.get("view.vlookat");
			
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
			if(arg==undefined || arg === null || arg == "")
				isAdaptiveVOffset = !isAdaptiveVOffset;
			else
				isAdaptiveVOffset = Boolean(arg); 
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
					factor,
					hlookatnow = krpano.get("view.hlookat"),
					vlookatnow = krpano.get("view.vlookat");

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
				hoffset += hlookatnow - hlookat;
				voffset += vlookatnow - vlookat;
				
				// clamp voffset
				if(Math.abs( pitch + voffset ) > 90) {
					voffset = ( pitch+voffset > 0 ) ? (90 - pitch) : (-90 - pitch)
				}

				hlookat = (-yaw -180 + hoffset ) % 360;
				vlookat = Math.max(Math.min(( pitch + voffset ),90),-90);

				// dampen lookat
				if(Math.abs(hlookat - hlookatnow) > 180) 
					hlookatnow += (hlookat > hlookatnow)?360:-360;
				hlookat = (1-isEasing)*hlookat + isEasing*hlookatnow;
				vlookat = (1-isEasing)*vlookat + isEasing*vlookatnow;
								
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
		
		return { toString: function() { return "[object krpanoGyro]"; } };
	};
}

// Comment out or edit the following line if you want to use a custom krpano object or a different object name
krpanoGyro();
