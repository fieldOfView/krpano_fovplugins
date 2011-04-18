/*
vectormath plugin for KRPano
by Aldo Hoeben

http://fieldofview.github.com/krpano_fovplugins/vectormath/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

package {
	import flash.display.*;
	import flash.text.*;	
	import flash.events.*;
	import flash.geom.*;
	
	import krpano_as3_interface;
	
	// SWF Metadata
	[SWF(width="256", height="256", backgroundColor="#000000")]

	public class vectormath extends Sprite {
		private var krpano:krpano_as3_interface = null;
		public var plugin_object:Object = null;
				
		public function vectormath() {
			if (stage == null) {
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			} else {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				var format:TextFormat = new TextFormat();
				format.font = "_sans";
				format.size = 14;
				format.align = "center";
				var txt:TextField = new TextField();
				txt.textColor = 0xffffff;
				txt.selectable = false;
				txt.htmlText = "<b>vectormath plugin</b> for KRPano" + "\n\n" + "Aldo Hoeben / fieldOfView.com";
				txt.autoSize = "center";
				txt.setTextFormat(format);
				addChild(txt);
				
				var resize:Function = function (event:Event) : void {
					txt.x = (stage.stageWidth - txt.width) / 2;
					txt.y = (stage.stageHeight - txt.height) / 2;
					return;
				}
			
				stage.addEventListener(Event.RESIZE, resize);
				resize(null);
			}
			return;
		}
		
		private function startPlugin(event:Event) : void {
			this.krpano = krpano_as3_interface.getInstance();
			
			this.krpano.addPluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			
			return;
		}

		private function stopPlugin(event:Event) : void {
			this.krpano.removePluginEventListener(this, krpano_as3_interface.PLUGINEVENT_REGISTER, this.registerPlugin);
			
			this.plugin_object = null;
			this.krpano = null;
			return;
		}
		
		private function registerPlugin(event:DataEvent) : void {
			this.plugin_object = this.krpano.get(event.data);
			
			this.plugin_object.registerattribute("sin", this.interface_sin);
			this.plugin_object.registerattribute("cos", this.interface_cos);
			this.plugin_object.registerattribute("tan", this.interface_tan);
			this.plugin_object.registerattribute("asin", this.interface_asin);
			this.plugin_object.registerattribute("acos", this.interface_acos);
			this.plugin_object.registerattribute("atan", this.interface_atan);
			this.plugin_object.registerattribute("atan2", this.interface_atan2);

			this.plugin_object.registerattribute("anglebetween", this.interface_anglebetween);			
			this.plugin_object.registerattribute("normal", this.interface_normal);
			this.plugin_object.registerattribute("rotatevector", this.interface_rotate);
			
			return;
		}
	
		
		public function interface_sin(varname:String="", angle:Number=0) : void {
			// sine from angle in degrees
			this.krpano.set(varname, Math.sin(degrad(angle)) );
		}
		public function interface_cos(varname:String="", angle:Number=0) : void {
			// cosine from angle in degrees
			this.krpano.set(varname, Math.cos(degrad(angle)) );
		}
		public function interface_tan(varname:String="", angle:Number=0) : void {
			// tangens from angle in degrees
			this.krpano.set(varname, Math.tan(degrad(angle)) );
		}
		public function interface_asin(varname:String="", real:Number=0) : void {
			// arcsine in degrees
			this.krpano.set(varname, raddeg(Math.asin(real)) );
		}
		public function interface_acos(varname:String="", real:Number=0) : void {
			// arccosine in degrees
			this.krpano.set(varname, raddeg(Math.acos(real)) );
		}
		public function interface_atan(varname:String="", real:Number=0) : void {
			// arctan in degrees
			this.krpano.set(varname, raddeg(Math.atan(real)) );
		}
		public function interface_atan2(varname:String="", real1:Number=0, real2:Number=0) : void {
			// arctan2 in degrees
			this.krpano.set(varname, raddeg(Math.atan2(real1, real2)) );		
		}

		public function interface_anglebetween(varname:String="", 
				pan1:Number=0, tilt1:Number=0, pan2:Number=0, tilt2:Number=0) : void {
			// smallest angle between two spherical coordinate vectors
			var vector1:Vector3D = polarcarthesian(new Point(pan1, tilt1));
			var vector2:Vector3D = polarcarthesian(new Point(pan2, tilt2));
			
			this.krpano.set(varname, raddeg(Vector3D.angleBetween(vector1, vector2)));			
		}
		
		public function interface_normal(pan_varname:String="", tilt_varname:String="", 
				pan1:Number=0, tilt1:Number=0, pan2:Number=0, tilt2:Number=0) : void {
			// cross product in spherical coordinates from two spherical coordinate vectors, all in degrees
			var vector1:Vector3D = polarcarthesian(new Point(pan1, tilt1));
			var vector2:Vector3D = polarcarthesian(new Point(pan2, tilt2));
			var normal:Point = carthesianpolar(vector1.crossProduct(vector2));
					
			this.krpano.set(pan_varname, normal.x);
			this.krpano.set(tilt_varname, normal.y);			
		}
		
		public function interface_rotate(
				pan_varname:String="", tilt_varname:String="", roll_varname:String="", 
				pan1:Number=0, tilt1:Number=0, roll1:Number=0, 	
				pan2:Number=0, tilt2:Number=0, roll2:Number=0 ) : void {
			// rotate a vector specified in spherical coordinates by another vector in spherical coordinates	
			
			var matrix:Matrix3D = eulermatrix(new Vector3D(degrad(roll1),degrad(pan1),degrad(tilt1)));
			matrix.append(        eulermatrix(new Vector3D(degrad(roll2),degrad(pan2),degrad(tilt2))));
			var euler:Vector3D = matrixeuler(matrix);

			this.krpano.set(pan_varname,  raddeg(euler.y));
			this.krpano.set(tilt_varname, raddeg(euler.z));
			this.krpano.set(roll_varname, raddeg(euler.x));			
		}

		/*
		 * Utility functions
		 */
		
		// deg <-> rad
		private function degrad(deg:Number=0):Number {
			return deg/180 * Math.PI;
		}
		private function raddeg(rad:Number=0):Number {
			return rad*180 / Math.PI;
		}
		
		// polar <-> carthesian coordinates
		// note: polar coordinates are expressed in degrees
		private function polarcarthesian(polar:Point):Vector3D {
			var carthesian:Vector3D = new Vector3D();
			carthesian.x = Math.sin(degrad(90-polar.y)) * Math.cos(degrad(polar.x));
			carthesian.y = Math.sin(degrad(90-polar.y)) * Math.sin(degrad(polar.x));
			carthesian.z = Math.cos(degrad(90-polar.y));
						
			return carthesian;
		}
		private function carthesianpolar(carthesian:Vector3D):Point {
			var polar:Point = new Point();
			polar.x = raddeg(Math.atan2(carthesian.y, carthesian.x));
			polar.y = 90-raddeg(Math.acos(carthesian.z / carthesian.length));
						
			return polar;
		}	
		
		// euler <-> matrix description
		// note: euler vectors are expressed in radians, 
		// axes: bank/roll around x-axis, heading/yaw around y-axis, attitude/pitch around z-axis
		// order: heading/yaw,attitude/pitch,bank/roll
		private function eulermatrix(euler:Vector3D):Matrix3D {
			// http://www.euclideanspace.com/maths/geometry/rotations/conversions/eulerToMatrix/index.htm
			
			var ch:Number = Math.cos(euler.y);
			var sh:Number = Math.sin(euler.y);
			var ca:Number = Math.cos(euler.z);
			var sa:Number = Math.sin(euler.z);
			var cb:Number = Math.cos(euler.x);
			var sb:Number = Math.sin(euler.x);

			return new Matrix3D(Vector.<Number>([
				ch * ca,	sh*sb - ch*sa*cb,	ch*sa*sb + sh*cb,	0,
				sa,			ca*cb,				-ca*sb,				0,
				-sh*ca,		sh*sa*cb + ch*sb,	-sh*sa*sb + ch*cb,	0,
				0,			0,					0,					0
			]));	
		}
		
		private function matrixeuler(matrix:Matrix3D):Vector3D {
			// http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToEuler/index.htm
			var heading:Number;
			var bank:Number;
			var attitude:Number;
			
			var m:Vector.<Number> = matrix.rawData;
			/* [m00 m01 m02 m03]
			 * [m10 m11 m12 m13]
			 * [m20 m21 m22 m23] 
			 * [m30 m31 m32 m33] 
			 */

			if (m[4] == 1) { // singularity at north pole
				heading = Math.atan2(m[2],m[10]);
				attitude = Math.PI/2;
				bank = 0;
			} else if (m[4] == -1) { // singularity at south pole
				heading = Math.atan2(m[2],m[10]);
				attitude = -Math.PI/2;
				bank = 0;
			} else {
				heading = Math.atan2(-m[8],m[0]);
				bank = Math.atan2(-m[6],m[5]);
				attitude = Math.asin(m[4]);
			}
			
			return new Vector3D(
				bank, heading, attitude
			);
		}
	}
}