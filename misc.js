/*
misc plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/misc/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){var b=this,d=null,c=null;b.registerplugin=function(g,f,h){d=g;c=h;if(d.version<"1.0.8.14"||d.build<"2011-03-30"){d.trace(3,"misc plugin - too old krpano version (min. 1.0.8.14)");return}c.forloop=a;c.abs=e};b.unloadplugin=function(){c=null;d=null};function e(g,f){d.set(g,Math.abs(f))}function a(k,i,g,f,h){i=parseFloat(i);g=parseFloat(g);f=parseFloat(f);if(h==""||f==0){return}var j=i;d.set(k,j);while((f>0&&j<=g)||(f<0&&j>=g)){d.call(h);j+=f;d.set(k,j)}d.set(k,g)}};
	
