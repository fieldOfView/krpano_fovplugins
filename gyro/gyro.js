/*
	krpano iOS 4.2 gyroscope script
	by Aldo Hoeben / fieldofview.com
	contributions by 
		Sjeiti / ronvalstar.nl
		Klaus / krpano.com
		
	https://github.com/fieldOfView/krpano_fovplugins/gyro
	This software can be used free of charge and the source code is available under a Creative Commons Attribution license:
		http://creativecommons.org/licenses/by/3.0/		
*/
var krpanoplugin=function(){function s(){if(v&&!j){window.addEventListener("deviceorientation",w,true);c.control.layer.addEventListener("touchstart",x,true);c.control.layer.addEventListener("touchend",p,true);c.control.layer.addEventListener("touchcancel",p,true);j=true}else j=false}function q(){if(v&&j){window.removeEventListener("deviceorientation",w);c.control.layer.removeEventListener("touchstart",x);c.control.layer.removeEventListener("touchend",p);c.control.layer.removeEventListener("touchcancel",
p)}j=false}function y(){j?q():s()}function x(){t=true}function p(){t=false}function w(i){if(!t&&j){var f,d=Object({yaw:i.alpha*m,pitch:i.beta*m,roll:i.gamma*m}),a,b;f=Math.cos(d.yaw);a=Math.sin(d.yaw);b=Math.cos(d.pitch);var e=Math.sin(d.pitch),g=Math.cos(d.roll);d=Math.sin(d.roll);matrix=Array(a*d-f*e*g,-f*b,f*e*d+a*g,b*g,-e,-b*d,a*e*g+f*d,a*b,-a*e*d+f*g);if(matrix[3]>0.9999){f=Math.atan2(matrix[2],matrix[8]);b=Math.PI/2;a=0}else if(matrix[3]<-0.9999){f=Math.atan2(matrix[2],matrix[8]);b=-Math.PI/
2;a=0}else{f=Math.atan2(-matrix[6],matrix[0]);a=Math.atan2(-matrix[5],matrix[4]);b=Math.asin(matrix[3])}f=Object({yaw:f,pitch:b,roll:a});a=f.yaw/m;b=f.pitch/m;e=a;g=c.view.hlookat;d=c.view.vlookat;if(Math.abs(b)>70){e=i.alpha;switch(window.orientation){case 0:if(b>0)e+=180;break;case 90:e+=90;break;case -90:e+=-90;break;case 180:if(b<0)e+=180;break}e%=360;if(Math.abs(e-a)>180)e+=e<a?360:-360;i=Math.min(1,(Math.abs(b)-70)/10);a=a*(1-i)+e*i}u+=g-l;h+=d-o;if(Math.abs(b+h)>90)h=b+h>0?90-b:-90-b;l=(-a-
180+u)%360;o=Math.max(Math.min(b+h,90),-90);if(Math.abs(l-g)>180)g+=l>g?360:-360;l=(1-n)*l+n*g;o=(1-n)*o+n*d;c.view.hlookat=l;c.view.vlookat=o;if(h!=0&&r){h*=0.98;if(Math.abs(h)<0.1)h=0}}}var c=null,k=null,v=!!window.DeviceOrientationEvent,j=false,r=false,n=0.5,t=false,u=0,h=0,l=0,o=0,m=Math.PI/180;this.registerplugin=function(i,f,d){c=i;k=d;if(c.version<"1.0.8.14"||c.build<"2011-03-30")c.trace(3,"gyro plugin - too old krpano version (min. 1.0.8.14)");
else{k.registerattribute("enabled",true,function(a){String("yesontrue1").indexOf(String(a).toLowerCase())>=0?s():q()},function(){return j});k.registerattribute("adaptivev",false,function(a){r=a==undefined||a===null||a==""?!r:String("yesontrue1").indexOf(String(a).toLowerCase())>=0},function(){return r});k.registerattribute("easing",false,function(a){n=Math.max(Math.min(Number(a),1),0)},function(){return n});k.enable=s;k.disable=q;k.toggle=y;u=c.view.hlookat;h=c.view.vlookat}};this.unloadplugin=function(){q();
c=k=null}};
