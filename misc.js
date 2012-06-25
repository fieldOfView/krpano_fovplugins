/*
misc plugin for KRPanoJS
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/misc/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){function g(d,a){c.set(d,Math.abs(void 0!=a?a:this.krpano.get(d)))}function h(d,a,e,b,f){a=parseFloat(a);e=parseFloat(e);b=parseFloat(b);if(!(""==f||0==b)){for(c.set(d,a);0<b&&a<=e||0>b&&a>=e;)c.call(f),a+=b,c.set(d,a);c.set(d,e)}}function i(b){if(1<arguments.length){value=arguments[1];for(var a=2;a<arguments.length;a++)value=Math.max(value,arguments[a])}this.krpano.set(b,value)}function j(b){if(1<arguments.length){value=arguments[1];for(var a=2;a<arguments.length;a++)value= Math.min(value,arguments[a])}this.krpano.set(b,value)}var c=null,b=null;this.registerplugin=function(d,a,e){c=d;b=e;"1.0.8.14">c.version||"2011-03-30">c.build?c.trace(3,"misc plugin - too old krpano version (min. 1.0.8.14)"):(b.forloop=h,b.abs=g,b.min=j,b.max=i)};this.unloadplugin=function(){c=b=null}};