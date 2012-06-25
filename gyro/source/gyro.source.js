/*
gyro plugin for KRPanoJS and iOS4.2+
by Aldo Hoeben / fieldOfView.com
with contributions by
	Sjeiti / ronvalstar.nl
	Klaus / krpano.com

http://fieldofview.github.com/krpano_fovplugins/gyro/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/
*/

var krpanoplugin = function()
{
	var local = this,
		krpano = null, plugin = null,
		isTopAccessible = false,	

		isDeviceAvailable,
		isEnabled = false,
		vElasticity = 0,
		isVRelative = false,
		isCamRoll = false,
		friction = 0.5,

		isTouching = false,
		validSample = false,
		firstSample = null,
		hOffset = 0, vOffset = 0,
		hLookAt = 0, vLookAt = 0, camRoll = 0,
		vElasticSpeed = 0,

		degRad = Math.PI/180;

	////////////////////////////////////////////////////////////
	// plugin management

	local.registerplugin = function(krpanointerface, pluginpath, pluginobject)
	{
		krpano = krpanointerface;
		plugin = pluginobject;

		if (krpano.version < "1.0.8.14" || krpano.build < "2011-03-30")
		{
			krpano.trace(3,"gyro plugin - too old krpano version (min. 1.0.8.14)");
			return;
		}
		
		isTopAccessible = krpano._have_top_access;
		if (isTopAccessible === undefined)
		{
			// old krpano version - test manually for top access
			isTopAccessible = false;
			try{ if (top && top.document) isTopAccessible = true; }catch(e){}
		}

		// Initiate device check
		if(!!window.DeviceOrientationEvent)
			window.addEventListener("deviceorientation", handleDeviceCheck);

		// Register attributes
		plugin.registerattribute("available",false, function(arg){}, function(){ return isDeviceAvailable; });
		plugin.registerattribute("enabled",  true,  function(arg){ stringToBoolean(arg) ? enable() : disable() }, function(){ return isEnabled; });
		plugin.registerattribute("velastic", 0,		function(arg){ vElasticity = Math.max(Math.min(Number(arg), 1), 0); }, function() { return vElasticity; });
		plugin.registerattribute("vrelative", false,function(arg){ isVRelative = stringToBoolean(arg); }, function() { return isVRelative; });
		plugin.registerattribute("camroll",  false, function(arg){ isCamRoll = stringToBoolean(arg); }, function() { return isCamRoll; });
		plugin.registerattribute("friction",   0.5,   function(arg){ friction = Math.max(Math.min(Number(arg), 1), 0); }, function() { return friction; });
		
		// Register events
		plugin.registerattribute("onavailable", null);

		// Register methods
		plugin.enable  = enable;
		plugin.disable = disable;
		plugin.toggle  = toggle;
	}


	local.unloadplugin = function()
	{
		window.removeEventListener("deviceorientation", handleDeviceCheck);
		disable();

		plugin = null;
		krpano = null;
	}


	////////////////////////////////////////////////////////////
	// public methods

	function enable()
	{
		validSample = false;
		firstSample = null;
	
		if (isDeviceAvailable === undefined)
		{
			isEnabled = true;
			return;
		}

		if (isDeviceAvailable && !isEnabled)
		{
			window.addEventListener("deviceorientation", handleDeviceOrientation,  true);
			krpano.control.layer.addEventListener("touchstart",  handleTouchStart, true);
			krpano.control.layer.addEventListener("touchend",    handleTouchEnd,   true);
			krpano.control.layer.addEventListener("touchcancel", handleTouchEnd,   true);
			isEnabled = true;

			hOffset = -(isTopAccessible ? top.orientation : window.orientation);
			vOffset = 0;
			hLookAt = 0;
			vLookAt = 0;
			camRoll = krpano.view.camroll;
		}
		else
		{
			isEnabled = false;
		}
	}

	function disable()
	{
		if (isDeviceAvailable && isEnabled)
		{
			window.removeEventListener("deviceorientation", handleDeviceOrientation, true);
			krpano.control.layer.removeEventListener("touchstart",  handleTouchStart);
			krpano.control.layer.removeEventListener("touchend",    handleTouchEnd);
			krpano.control.layer.removeEventListener("touchcancel", handleTouchEnd);
		}
		
		if (isCamRoll) 
		{
			krpano.call("tween(view.camroll,0)");
		}

		isEnabled = false;
	}

	function toggle()
	{
		if(isEnabled)
			disable();
		else
			enable();
	}

	////////////////////////////////////////////////////////////
	// private methods

	function handleDeviceCheck(event)
	{
		// Confirm that deviceorientation events are being generated
		isDeviceAvailable = true;

		window.removeEventListener("deviceorientation", handleDeviceCheck);

		// If this event came after any event that set the "enabled" property, call enable() now
		if(isEnabled)
		{
			isEnabled = false;
			enable();
		}
		
		// Call onavailable actions in krpano xml
		if (plugin.onavailable != null)
			krpano.call(plugin.onavailable, plugin);
	}

	function handleTouchStart(event)
	{
		isTouching = true;
	}

	function handleTouchEnd(event)
	{
		isTouching = false;
	}

	function handleDeviceOrientation(event)
	{
		if ( !isTouching && isEnabled )	{
			// Process event.alpha, event.beta and event.gamma
			var deviceOrientation = isTopAccessible ? top.orientation : window.orientation,
				orientation = rotateEuler({
						yaw: event["alpha"] * degRad,
						pitch: event["beta"] * degRad,
						roll: event["gamma"] * degRad
				}),
				yaw = wrapAngle( orientation.yaw / degRad ),
				pitch = orientation.pitch / degRad,
				altYaw = yaw,
				factor,
				hLookAtNow = krpano.view.hlookat,
				vLookAtNow = krpano.view.vlookat,
				camRollNow = krpano.view.camroll,
				hSpeed = hLookAtNow - hLookAt,
				vSpeed = vLookAtNow - vLookAt;

			// Ignore all sample untill we get a sample that is different from the first sample
			if(!validSample) 
			{
				if( firstSample == null ) 
					firstSample = orientation;
				else 
				{
					if( orientation.yaw!=firstSample.yaw || orientation.pitch!=firstSample.pitch || orientation.roll!=firstSample.roll ) 
					{
						firstSample = null;
						validSample = true;
						if( isVRelative ) 
							vOffset = -pitch;
					}					
				}
				return;
			}
				
			if( isCamRoll ) {
				camRoll = wrapAngle( 180 + Number(deviceOrientation) - orientation.roll  / degRad );
			}

			// Fix gimbal lock
			if( Math.abs(pitch) > 70 )
			{
				altYaw = event.alpha;

				switch(deviceOrientation)
				{
					case 0:
						if ( pitch>0 )
							altYaw += 180;
						break;
					case 90:
						altYaw += 90;
						break;
					case -90:
						altYaw += -90;
						break;
					case 180:
						if ( pitch<0 )
							altYaw += 180;
						break;
				}

				altYaw = wrapAngle(altYaw);
				if( Math.abs( altYaw - yaw ) > 180 )
					altYaw += ( altYaw < yaw ) ? 360 : -360;

				factor = Math.min( 1, ( Math.abs( pitch ) - 70 ) / 10 );
				yaw = yaw * (1 - factor) + altYaw * factor;

				camRoll *= (1 - factor);
			}

			// Track view change since last orientation event
			// ie: user has manually panned, or krpano has altered lookat
			hOffset += hSpeed;
			vOffset += vSpeed;

			// Clamp vOffset
			if(Math.abs( pitch + vOffset ) > 90)
				vOffset = ( pitch+vOffset > 0 ) ? (90 - pitch) : (-90 - pitch)

			hLookAt = wrapAngle(-yaw -180 + hOffset );
			vLookAt = Math.max(Math.min(( pitch + vOffset ),90),-90);

			// Dampen lookat
			if(Math.abs(hLookAt - hLookAtNow) > 180)
				hLookAtNow += (hLookAt > hLookAtNow)?360:-360;

			hLookAt = (1-friction)*hLookAt + friction*hLookAtNow;
			vLookAt = (1-friction)*vLookAt + friction*vLookAtNow;

			if(Math.abs(camRoll - camRollNow) > 180)
				camRollNow += (camRoll > camRollNow)?360:-360;
			camRoll = (1-friction)*camRoll + friction*camRollNow;

			krpano.view.hlookat = wrapAngle(hLookAt);
			krpano.view.vlookat = vLookAt;
			krpano.view.camroll = wrapAngle(camRoll);

			if( vOffset != 0 && vElasticity > 0 )
			{
				if( vSpeed == 0)
				{
					if( vElasticity == 1)
					{
						vOffset = 0;
						vElasticSpeed = 0;
					}
					else
					{
						vElasticSpeed = 1 - ((1 - vElasticSpeed) * krpano.control.touchfriction);
						vOffset *= 1 - (Math.pow(vElasticity,2) * vElasticSpeed); // use Math.pow to be able to use saner values

						if( Math.abs( vOffset ) < 0.1 ) {
							vOffset = 0;
							vElasticSpeed = 0;
						}
					}
				}
				else
					vElasticSpeed = 0;
			}
		}
	}

	function rotateEuler( euler )
	{
		// This function is based on http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToMatrix/index.htm
		// and http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToEuler/index.htm

		var heading, bank, attitude,
			ch = Math.cos(euler.yaw),
			sh = Math.sin(euler.yaw),
			ca = Math.cos(euler.pitch),
			sa = Math.sin(euler.pitch),
			cb = Math.cos(euler.roll),
			sb = Math.sin(euler.roll),

			matrix = [
				sh*sb - ch*sa*cb,   -ch*ca,    ch*sa*sb + sh*cb,
				ca*cb,              -sa,      -ca*sb,
				sh*sa*cb + ch*sb,    sh*ca,   -sh*sa*sb + ch*cb
			]; // Note: Includes 90 degree rotation around z axis

		/* [m00 m01 m02] 0 1 2
		 * [m10 m11 m12] 3 4 5
		 * [m20 m21 m22] 6 7 8 */

		if (matrix[3] > 0.9999)
		{
			// Deal with singularity at north pole
			heading = Math.atan2(matrix[2],matrix[8]);
			attitude = Math.PI/2;
			bank = 0;
		}
		else if (matrix[3] < -0.9999)
		{
			// Deal with singularity at south pole
			heading = Math.atan2(matrix[2],matrix[8]);
			attitude = -Math.PI/2;
			bank = 0;
		}
		else
		{
			heading = Math.atan2(-matrix[6],matrix[0]);
			bank = Math.atan2(-matrix[5],matrix[4]);
			attitude = Math.asin(matrix[3]);
		}

		return { yaw:heading, pitch:attitude, roll:bank };
	}

	////////////////////////////////////////////////////////////
	// utility functions

	function wrapAngle(value)	{ value = value % 360; return (value<=180)? value : value-360;	} // wrap a value between -180 and 180
	function stringToBoolean(value) { return (String("yesontrue1").indexOf( String(value).toLowerCase() ) >= 0); };	// boolean cast helper function
}