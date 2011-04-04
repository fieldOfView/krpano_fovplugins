/*
	krpano iOS 4.2 gyroscope script
	by Aldo Hoeben / fieldofview.com
	contributions by 
		Sjeiti / ronvalstar.nl
		Klaus / krpano.com
		
	https://github.com/fieldOfView/krpano_fovplugins/gyro
	This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
		http://creativecommons.org/licenses/by/3.0/		
*/

var krpanoplugin = function()
{
	function BOOLEAN(value) { return (String("yesontrue1").indexOf( String(value).toLowerCase() ) >= 0); };	// boolen cast helper function
	
	var local = this;
	
	var krpano = null;
	var plugin = null;
	
	var isDeviceEnabled = !!window.DeviceOrientationEvent;
	var isEnabled = false;
	var isAdaptiveVOffset = false;
	var isEasing = 0.5;

	var	isTouching = false;
	var hoffset = 0, voffset = 0, hlookat = 0, vlookat = 0;
			
	var degRad = Math.PI/180;
			
	
	// registerplugin - startup point for the plugin
	local.registerplugin = function(krpanointerface, pluginpath, pluginobject)
	{
		krpano = krpanointerface;
		plugin = pluginobject;
		
		if (krpano.version < "1.0.8.14" || krpano.build < "2011-03-30")
		{
			krpano.trace(3,"gyro plugin - too old krpano version (min. 1.0.8.14)");
			return;
		}

		plugin.registerattribute("enabled",   true,  function(arg){ BOOLEAN(arg) ? enable() : disable() }, function(){ return isEnabled; });
		plugin.registerattribute("adaptivev", false, function(arg){ setAdaptiveVOffset(arg); }, function() { return isAdaptiveVOffset; });
		plugin.registerattribute("easing",    false, function(arg){ isEasing = Math.max(Math.min(Number(arg), 1), 0); }, function() { return isEasing; });
		
		plugin.enable  = enable;
		plugin.disable = disable;
		plugin.toggle  = toggle;
			
		// get offsets for defaultview
		hoffset = krpano.view.hlookat;
		voffset = krpano.view.vlookat;
	}
		
		
	local.unloadplugin = function()
	{
		disable();
		
		plugin = null;
		krpano = null;
	}
	
	
	////////////////////////////////////////////////////////////
		
	function enable()
	{
		if (isDeviceEnabled && !isEnabled)
		{
			window.addEventListener("deviceorientation", handleDeviceOrientation, true);
			krpano.control.layer.addEventListener("touchstart",  handleTouchStart, true);
			krpano.control.layer.addEventListener("touchend",    handleTouchEnd,   true);		
			krpano.control.layer.addEventListener("touchcancel", handleTouchEnd,   true);	
			isEnabled = true;
		}
		else
		{
			isEnabled = false;
		}
	}

	function disable()
	{
		if (isDeviceEnabled && isEnabled)
		{
			window.removeEventListener("deviceorientation", handleDeviceOrientation);
			krpano.control.layer.removeEventListener("touchstart",  handleTouchStart);
			krpano.control.layer.removeEventListener("touchend",    handleTouchEnd);		
			krpano.control.layer.removeEventListener("touchcancel", handleTouchEnd);	
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
		
	function setAdaptiveVOffset(arg)
	{
		if(arg==undefined || arg === null || arg == "")
			isAdaptiveVOffset = !isAdaptiveVOffset;
		else
			isAdaptiveVOffset = BOOLEAN(arg); 
	}

	////////////////////////////////////////////////////////////
		
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
		if ( !isTouching && isEnabled )
		{
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
				hlookatnow = krpano.view.hlookat,
				vlookatnow = krpano.view.vlookat;

			// fix gimbal lock
			if( Math.abs(pitch) > 70 )
			{
				altyaw = event.alpha; 
					
				switch(window.orientation)
				{
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
					case 180:
						if ( pitch<0 ) 
							altyaw += 180;
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
			if(Math.abs( pitch + voffset ) > 90)
			{
				voffset = ( pitch+voffset > 0 ) ? (90 - pitch) : (-90 - pitch)
			}

			hlookat = (-yaw -180 + hoffset ) % 360;
			vlookat = Math.max(Math.min(( pitch + voffset ),90),-90);

			// dampen lookat
			if(Math.abs(hlookat - hlookatnow) > 180) 
				hlookatnow += (hlookat > hlookatnow)?360:-360;
			
			hlookat = (1-isEasing)*hlookat + isEasing*hlookatnow;
			vlookat = (1-isEasing)*vlookat + isEasing*vlookatnow;
			
			krpano.view.hlookat = hlookat;
			krpano.view.vlookat = vlookat;
			krpano.view.camroll = 180 + Number(window.orientation) - orientation.roll  / degRad;	// camroll added
				
			adaptVOffset();
		}
	}

	function adaptVOffset()
	{
		if( voffset != 0 && isAdaptiveVOffset )
		{
			voffset *= 0.98;
			if( Math.abs( voffset ) < 0.1 ) 
			{
				voffset = 0;
			}
		}
	}

	
	function rotateEuler( euler )
	{
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
		matrix = new Array
			( 
				sh*sb - ch*sa*cb,   -ch*ca,    ch*sa*sb + sh*cb,
				ca*cb,              -sa,      -ca*sb,			
				sh*sa*cb + ch*sb,    sh*ca,   -sh*sa*sb + ch*cb
			);
						
		/* [m00 m01 m02] 0 1 2
		 * [m10 m11 m12] 3 4 5 
		 * [m20 m21 m22] 6 7 8 */
			 
		if (matrix[3] > 0.9999)
		{ 
			// singularity at north pole
			heading = Math.atan2(matrix[2],matrix[8]);
			attitude = Math.PI/2;
			bank = 0;
		} 
		else if (matrix[3] < -0.9999) 
		{ 
			// singularity at south pole
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
			
		return new Object( { yaw:heading, pitch:attitude, roll:bank } ) 
	}
}

