/**
 * jquery.placeholder http://matoilic.github.com/jquery.placeholder
 *
 * @version v0.2.4
 * @author Mato Ilic <info@matoilic.ch>
 * @copyright 2013 Mato Ilic
 *
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 */
!function(e,a,t){function r(){e(this).find(c).each(n)}function l(e){for(var e=e.attributes,a={},t=/^jQuery\d+/,r=0;r<e.length;r++)e[r].specified&&!t.test(e[r].name)&&(a[e[r].name]=e[r].value);return a}function n(){var a,t=e(this);t.is(":password")||(t.data("password")?(a=t.next().show().focus(),e("label[for="+t.attr("id")+"]").attr("for",a.attr("id")),t.remove()):t.realVal()==t.attr("placeholder")&&(t.val(""),t.removeClass("placeholder")))}function o(){var a,t,r=e(this);placeholder=r.attr("placeholder"),e.trim(r.val()).length>0||(r.is(":password")?(t=r.attr("id")+"-clone",a=e("<input/>").attr(e.extend(l(this),{type:"text",value:placeholder,"data-password":1,id:t})).addClass("placeholder"),r.before(a).hide(),e("label[for="+r.attr("id")+"]").attr("for",t)):(r.val(placeholder),r.addClass("placeholder")))}var d="placeholder"in a.createElement("input"),i="placeholder"in a.createElement("textarea"),c=":input[placeholder]";e.placeholder={input:d,textarea:i},!t&&d&&i?e.fn.placeholder=function(){}:(!t&&d&&!i&&(c="textarea[placeholder]"),e.fn.realVal=e.fn.val,e.fn.val=function(){var a,t=e(this);return arguments.length>0?t.realVal.apply(this,arguments):(a=t.realVal(),t=t.attr("placeholder"),a==t?"":a)},e.fn.placeholder=function(){return this.filter(c).each(o),this},e(function(e){var t=e(a);t.on("submit","form",r),t.on("focus",c,n),t.on("blur",c,o),e(c).placeholder()}))}(jQuery,document,window.debug);