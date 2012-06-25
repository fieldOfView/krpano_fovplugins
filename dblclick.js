/*
dblclick plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/dblclick/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){function d(){a.call(b)}var a=null,c=null,b;this.registerplugin=function(e,g,f){a=e;c=f;"1.0.8.14">a.version||"2011-03-30">a.build?a.trace(3,"dblclick plugin - too old krpano version (min. 1.0.8.14)"):(c.registerattribute("ondblclick","",function(a){b=a},function(){return b}),a.control.layer.addEventListener("dblclick",d,!0))};this.unloadplugin=function(){a.control.layer.removeEventListener("dblclick",d);a=c=null}};