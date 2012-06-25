/*
	AS3 Interface for krpano
	1.0.8.14
	--
	krpano.com
*/

package
{
	public class krpano_as3_interface
	{
		public static var instance:krpano_as3_interface = null;


		public function krpano_as3_interface()
		{
		}


		public static function getInstance():krpano_as3_interface
		{
			if (instance == null)
			{
				instance = new krpano_as3_interface();
			}

			return instance;
		}



		// krpano interface
		public var set        : Function = null;
		public var get        : Function = null;
		public var call       : Function = null;
		public var trace      : Function = null;

		public var loadfile      : Function = null;
		public var loadobject    : Function = null;
		public var decodelicense : Function = null;


		// trace constants
		static public const STARTDEBUGMODE : int = 0xFF;	// not used anymore
		static public const DEBUG          : int = 0;
		static public const INFO           : int = 1;
		static public const WARNING        : int = 2;
		static public const ERROR          : int = 3;


		// plugin interface constants
		static public const PLUGINEVENT_REGISTER : String = "krpano.registerplugin";
		static public const PLUGINEVENT_RESIZE   : String = "krpano.resizeplugin";
		static public const PLUGINEVENT_UPDATE   : String = "krpano.updateplugin";


		// add/remove plugin event listeners
		public var addPluginEventListener    : Function = null;
		public var removePluginEventListener : Function = null;
	}
}
