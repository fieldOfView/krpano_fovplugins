krpano iOS 4.2.1 gyroscope script
by Aldo Hoeben / fieldofview.com
---------------------------------

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