/*
string plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/string/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){function e(b,d){c.set(b,d.length)}function g(b,d,a,f){c.set(b,d.substr(a,f))}function i(b,d,a){c.set(b,d.indexOf(a))}function j(b,d,a,f,e){c.set(b,d.replace(RegExp(a,e),f))}function k(b,d){var a=RegExp(find,flags);c.set(b,(void 0!=d?d:c.get(b)).replace(a,""))}function l(b,a){c.set(b,(void 0!=a?a:c.get(b)).toLowerCase())}function m(a,d){c.set(a,(void 0!=d?d:c.get(a)).toUpperCase())}var c=null,a=null;this.registerplugin=function(b,d,h){c=b;a=h;"1.0.8.14">c.version||"2011-03-30"> c.build?c.trace(3,"string plugin - too old krpano version (min. 1.0.8.14)"):(a.txtlength=e,a.txtchunk=g,a.txtfind=i,a.txtreplace=j,a.txttrim=k,a.txtlower=l,a.txtupper=m)};this.unloadplugin=function(){c=a=null}};