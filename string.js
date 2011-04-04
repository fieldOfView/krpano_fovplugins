/*
string plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/string/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){var c=this,f=null,d=null;c.registerplugin=function(i,h,j){f=i;d=j;if(f.version<"1.0.8.14"||f.build<"2011-03-30"){f.trace(3,"string plugin - too old krpano version (min. 1.0.8.14)");return}d.txtlength=a;d.txtchunk=g;d.txtfind=b;d.txtreplace=e};c.unloadplugin=function(){d=null;f=null};function a(i,h){f.set(i,h.length)}function g(k,h,j,i){f.set(k,h.substr(j,i))}function b(j,h,i){f.set(j,h.indexOf(i))}function e(m,j,l,i,h){var k=new RegExp(l,h);f.set(m,j.replace(k,i))}};