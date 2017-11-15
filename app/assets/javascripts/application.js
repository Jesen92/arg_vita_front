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
//= require bootstrap-sprockets
//= require jquery_ujs
//= require fakeloader
//= require filterrific/filterrific-jquery
//= require filter
//= require lightsliderInit
//= require lightslider
//= require sky-forms-ie8.js
//= require jquery.placeholder.min
//= require chosen-jquery
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
