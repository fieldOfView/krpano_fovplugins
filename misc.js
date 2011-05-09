/*
misc plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/misc/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){var c=this,e=null,d=null;c.registerplugin=function(i,h,j){e=i;d=j;if(e.version<"1.0.8.14"||e.build<"2011-03-30"){e.trace(3,"misc plugin - too old krpano version (min. 1.0.8.14)");return}d.forloop=b;d.abs=g;d.min=a;d.max=f};c.unloadplugin=function(){d=null;e=null};function g(i,h){e.set(i,Math.abs(((h!=undefined)?h:this.krpano.get(i))))}function b(m,k,i,h,j){k=parseFloat(k);i=parseFloat(i);h=parseFloat(h);if(j==""||h==0){return}var l=k;e.set(m,l);while((h>0&&l<=i)||(h<0&&l>=i)){e.call(j);l+=h;e.set(m,l)}e.set(m,i)}function f(j){if(arguments.length>1){value=arguments[1];for(var h=2;h<arguments.length;h++){value=Math.max(value,arguments[h])}}this.krpano.set(j,value)}function a(j){if(arguments.length>1){value=arguments[1];for(var h=2;h<arguments.length;h++){value=Math.min(value,arguments[h])}}this.krpano.set(j,value)}};