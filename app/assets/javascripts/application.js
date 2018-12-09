// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require chosen-jquery
//= require bootstrap-sprockets
//= require fakeloader
//= require filterrific/filterrific-jquery
//= require filter
//= require lightsliderInit
//= require lightslider
//= require sky-forms-ie8.js
//= require jquery.placeholder.min
//= require select_category
//= require wice_grid
//= require bootstrap-datepicker
//= require lightgallery
//= require jquery.infinite-pages
//= require articles.coffee
//= require sticky-kit
//= require memenu
//= require rangeslider_mousedown_up.js
//= require lightslider.js
//= require sticky-kit.js
//= require owl.carousel.js
//= require responsiveslides.min
//= require jquery.countdown.js
//= require ion.rangeSlider.min
//= require scaffold.coffee
//= require turbolinks
//= require cookies_eu
//= require_tree .


$(window).scroll(function() {
    if ($(this).scrollTop() >= 600) {        // If page is scrolled more than 50px
        $('#return-to-top').fadeIn(200);    // Fade in the arrow
    } else {
        $('#return-to-top').fadeOut(200);   // Else fade out the arrow
    }
});
$('#return-to-top').click(function() {      // When arrow is clicked
    $('body,html').animate({
        scrollTop : 0                       // Scroll to top of body
    }, 500);
});

////////

$(document).ready(function() {
    $('#imageGallery').lightSlider({
        gallery:true,
        item:1,
        loop:true,
        thumbItem:4,
        slideMargin:0,
        enableDrag: false,
        currentPagerPosition:'left',
        onSliderLoad: function(el) {
            el.lightGallery({
                selector: '#imageGallery .lslide'
            });
        }
    });
});

$(function () {
    $("#range").ionRangeSlider({
        hide_min_max: true,
        keyboard: false,
        min: gon.min,
        max: gon.max,
        from_max: gon.max-1,
        to_min: gon.min+1,
        from: gon.current_min,
        to: gon.current_max,
        type: 'double',
        step: 10,
        postfix: " kn",
        grid: true
    });

});

$(document).ready(function() {
    if (window.innerWidth <= 768) {
        $(window).resize();
    }
});
