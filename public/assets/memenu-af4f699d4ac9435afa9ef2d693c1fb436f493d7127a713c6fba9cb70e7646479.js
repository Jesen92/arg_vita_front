$.fn.memenu=function(n){function i(){$(".memenu").find("li, a").unbind(),window.innerWidth<=768?(o(),s(),0==m&&$(".memenu > li:not(.showhide)").hide(0)):(l(),e())}function e(){$(".memenu li").bind("mouseover",function(){$(this).children(".dropdown, .mepanel").stop().fadeIn(d.interval)}).bind("mouseleave",function(){$(this).children(".dropdown, .mepanel").stop().fadeOut(d.interval)})}function s(){$(".memenu > li > a").bind("click",function(n){"none"==$(this).siblings(".dropdown, .mepanel").css("display")?($(this).siblings(".dropdown, .mepanel").slideDown(d.interval),$(this).siblings(".dropdown").find("ul").slideDown(d.interval),m=1):$(this).siblings(".dropdown, .mepanel").slideUp(d.interval)})}function o(){$(".memenu > li.showhide").show(0),$(".memenu > li.showhide").bind("click",function(){$(".memenu > li").is(":hidden")?$(".memenu > li").slideDown(300):($(".memenu > li:not(.showhide)").slideUp(300),$(".memenu > li.showhide").show(0))})}function l(){$(".memenu > li").show(0),$(".memenu > li.showhide").hide(0)}var d={interval:250},m=0;$(".memenu").prepend("<li class='showhide'><span class='title'>MENU</span><span class='icon1'></span><span class='icon2'></span></li>"),i(),$(window).resize(function(){i()})};