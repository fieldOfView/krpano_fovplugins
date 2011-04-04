/*
dblclick plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/dblclick/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){var b=this,d=null,c=null,e;b.registerplugin=function(g,f,h){d=g;c=h;if(d.version<"1.0.8.14"||d.build<"2011-03-30"){d.trace(3,"dblclick plugin - too old krpano version (min. 1.0.8.14)");return}c.registerattribute("ondblclick","",function(i){e=i},function(){return e});d.control.layer.addEventListener("dblclick",a,true)};b.unloadplugin=function(){d.control.layer.removeEventListener("dblclick",a);c=null;d=null};function a(f){d.call(e)}};