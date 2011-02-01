/*
	krpano iOS 4.2.1 gyroscope script
	by Aldo Hoeben / fieldofview.com
	
	tested for krpano 1.0.8.12 (build 2010-11-24) and iPhone4

	Include krpanogyro.js in your html document:

<div id="krpanoDIV">
	<noscript><table width="100%" height="100%"><tr valign="middle"><td><center>ERROR:<br><br>Javascript not activated<br><br></center></td></tr></table></noscript>
</div>
	
<script type="text/javascript" src="swfkrpano.js"></script>
<script type="text/javascript" src="krpanogyro.js"></script>
<script type="text/javascript">
	var swf = createswf("krpano.swf");
	swf.addVariable("xml","santos_compo.xml");
	swf.embed("krpanoDIV");
</script>

	If you use a different div id, you will have to edit the gyro_objectname variable

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
var gyro_transform = eulerMatrix( new Object( { yaw:0, pitch:90*degRad, roll:0 } ) );


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
			var gyro_matrix = eulerMatrix( new Object( { 
				yaw: event["alpha"] * degRad, 
				pitch: event["beta"] * degRad, 
				roll: event["gamma"] * degRad 
			} ) );
			var gyro_vector = matrixEuler( multiply4x4( gyro_transform, gyro_matrix ) );
			
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

/*
 * Matrix math utility functions
 */

function eulerMatrix( euler ) {
	// http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToMatrix/index.htm
	
	var ch = Math.cos(euler.yaw);
	var sh = Math.sin(euler.yaw);
	var ca = Math.cos(euler.pitch);
	var sa = Math.sin(euler.pitch);
	var cb = Math.cos(euler.roll);
	var sb = Math.sin(euler.roll);

	return new Array( 
		ch * ca,	sh*sb - ch*sa*cb,	ch*sa*sb + sh*cb,	0,
		sa,			ca*cb,				-ca*sb,				0,
		-sh*ca,		sh*sa*cb + ch*sb,	-sh*sa*sb + ch*cb,	0,
		0,			0,					0,					0
	);				
}

function matrixEuler( matrix ) {
	// http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToEuler/index.htm
	var heading;
	var bank;
	var attitude;
	
	/* [m00 m01 m02 m03]
	 * [m10 m11 m12 m13]
	 * [m20 m21 m22 m23] 
	 * [m30 m31 m32 m33] 
	 */
		if (matrix[4] > 0.9999) { // singularity at north pole
			heading = Math.atan2(matrix[2],matrix[10]);
			attitude = Math.PI/2;
			bank = 0;
		} else if (matrix[4] < -0.9999) { // singularity at south pole
			heading = Math.atan2(matrix[2],matrix[10]);
			attitude = -Math.PI/2;
			bank = 0;
		} else {
			heading = Math.atan2(-matrix[8],matrix[0]);
			bank = Math.atan2(-matrix[6],matrix[5]);
			attitude = Math.asin(matrix[4]);
		}
	
	return new Object( { yaw:heading, pitch:attitude, roll:bank } ) 
}

function  multiply4x4(a, b) {
	// http://fhtr.blogspot.com/2009/03/4x4-matrix-multiplication-in-javascript.html
	
	// allocating the array values should be faster than doing the same dynamically
	var result = new Array(
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0
	);
		
	for (var i=0; i<16; i+=4) {
		result[i] =   b[i] * a[0] +
					  b[i+1] * a[4] +
					  b[i+2] * a[8] +
					  b[i+3] * a[12];
		result[i+1] = b[i] * a[1] +
					  b[i+1] * a[5] +
					  b[i+2] * a[9] +
					  b[i+3] * a[13];
		result[i+2] = b[i] * a[2] +
					  b[i+1] * a[6] +
					  b[i+2] * a[10] +
					  b[i+3] * a[14];
		result[i+3] = b[i] * a[3] +
					  b[i+1] * a[7] +
					  b[i+2] * a[11] +
					  b[i+3] * a[15];
	}
	return result;
}