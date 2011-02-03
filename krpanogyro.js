/*
	krpano iOS 4.2 gyroscope script
	by Aldo Hoeben / fieldofview.com
	
	tested for krpano 1.0.8.12 (build 2010-11-24) and iPhone4

	Include krpanogyro.js in your html document, eg:

<div id="krpanoDIV">
</div>
	
<script type="text/javascript" src="swfkrpano.js"></script>
<script type="text/javascript" src="krpanogyro.js"></script>
<script type="text/javascript">
	var swf = createswf("krpano.swf");
	swf.addVariable("xml","santos_compo.xml");
	swf.embed("krpanoDIV");
</script>

	In most cases just adding the krpanogyro.js script line should do the trick.
	If you use a different div id, you will have to edit the gyro_objectname variable.

This software is licensed under the CC-GNU GPL version 2.0 or later
http://creativecommons.org/licenses/GPL/2.0/
*/

var gyro_objectname = "krpanoSWFObject";
var gyro_krpano; 

var gyro_touching = false;
var gyro_hoffset = 0;
var gyro_voffset = 0;
var gyro_hoffset_start = 0;
var gyro_voffset_start = 0;

var gyro_offset_interval;

var degRad = Math.PI/180;

if( window["DeviceOrientationEvent"] ) {
	var gyro_init_interval = setInterval( function() {
		gyro_krpano = document.getElementById( gyro_objectname );	

		if(gyro_krpano) {
			clearInterval(gyro_init_interval);
			gyro_init();
		}
	}, 100 );
}

function gyro_init() {
	// get offsets for defaultview
	gyro_hoffset = gyro_krpano.get("view.hlookat") + 180;
	gyro_voffset = gyro_krpano.get("view.vlookat");

	gyro_smooth_voffset();
	
	gyro_krpano.addEventListener("touchstart", function(event) {
		gyro_hoffset_start = gyro_krpano.get("view.hlookat");
		gyro_voffset_start = gyro_krpano.get("view.vlookat");
		
		clearInterval(gyro_offset_interval);
		
		gyro_touching = true;
	}, true );
	gyro_krpano.addEventListener("touchend", function(event) {
		gyro_touchend(event);			
	}, true );		
	gyro_krpano.addEventListener("touchcancel", function(event) {
		gyro_touchend(event);
	}, true );		
	
	window.addEventListener("deviceorientation", function(event) {
		if ( !gyro_touching ) {
			// process event.alpha, event.beta and event.gamma
			var gyro_vector = rotateEuler( new Object( { 
				yaw: event["alpha"] * degRad, 
				pitch: event["beta"] * degRad, 
				roll: event["gamma"] * degRad 
			} ) );
			
			gyro_krpano.call( "lookat(" + 
				(-gyro_vector.yaw / degRad + gyro_hoffset )%360 + "," + 
				Math.max(Math.min(( gyro_vector.pitch / degRad + gyro_voffset ),90),-90) + ")" );
		}
	}, true);
}

function gyro_touchend(event) {
	gyro_hoffset += gyro_krpano.get("view.hlookat") - gyro_hoffset_start;
	gyro_voffset += gyro_krpano.get("view.vlookat") - gyro_voffset_start;

	gyro_smooth_voffset();
	
	gyro_touching = false;	
}

function gyro_smooth_voffset() {
	if( Math.abs( gyro_voffset ) > 0 ) {
		gyro_offset_interval = setInterval( function() {
			gyro_voffset *= 0.98;
			if( Math.abs( gyro_voffset ) < 0.1 ) {
				gyro_voffset = 0;
				clearInterval(gyro_offset_interval);
			}
		}, 10 );
	}
}

function rotateEuler( euler ) {
	// based on http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToMatrix/index.htm
	// and http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToEuler/index.htm

	
	var ch = Math.cos(euler.yaw);
	var sh = Math.sin(euler.yaw);
	var ca = Math.cos(euler.pitch);
	var sa = Math.sin(euler.pitch);
	var cb = Math.cos(euler.roll);
	var sb = Math.sin(euler.roll);

	// note: includes 90 degree rotation around z axis
	matrix = new Array( 
		sh*sb - ch*sa*cb,	-ch*ca,		 ch*sa*sb + sh*cb,
		ca*cb,				-sa,		-ca*sb,
		sh*sa*cb + ch*sb,	 sh*ca,		-sh*sa*sb + ch*cb
	);

	
	var heading;
	var bank;
	var attitude;
	
	/* [0:m00 1:m01 2:m02]
	 * [3:m10 4:m11 5:m12]
	 * [6:m20 7:m21 8:m22] */
	 
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