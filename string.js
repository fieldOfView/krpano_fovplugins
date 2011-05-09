/*
string plugin for KRPano
by Aldo Hoeben / fieldOfView.com

http://fieldofview.github.com/krpano_fovplugins/string/plugin.html
This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
	http://creativecommons.org/licenses/by/3.0/	
*/

var krpanoplugin=function(){var h=this,g=null,e=null;h.registerplugin=function(l,k,m){g=l;e=m;if(g.version<"1.0.8.14"||g.build<"2011-03-30"){g.trace(3,"string plugin - too old krpano version (min. 1.0.8.14)");return}e.txtlength=i;e.txtchunk=f;e.txtfind=d;e.txtreplace=a;e.txttrim=j;e.txtlower=b;e.txtupper=c};h.unloadplugin=function(){e=null;g=null};function i(l,k){g.set(l,k.length)}function f(n,k,m,l){g.set(n,k.substr(m,l))}function d(m,k,l){g.set(m,k.indexOf(l))}function a(p,m,o,l,k){var n=new RegExp(o,k);g.set(p,m.replace(n,l))}function j(m,k){var l=new RegExp(find,flags);g.set(m,((k!=undefined)?k:g.get(m)).replace(l,""))}function b(l,k){g.set(l,((k!=undefined)?k:g.get(l)).toLowerCase())}function c(l,k){g.set(l,((k!=undefined)?k:g.get(l)).toUpperCase())}};