(function() {
  var addImage, adjustBottomPanel, adjustCloseButton, adjustImage, adjustNavigationButtons, canShowNextAfter, canShowPreviousBefore, clearLoaderTimer, closeGallery, createBotomPanel, createCloseButton, createDarkening, createElement, createKeyBindings, createLeftNavigationButton, createLoader, createNavigationButton, createRightNavigationButton, hideCurrentImage, hideLoader, imageAt, indexOfImage, loadImage, nextIndexAfter, openGallery, preloadNeighboursFor, previousIndexBefore, root, showImage, showLoader, showNextImage, showPreviousImage, sourceFor, textFor;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.hermitage = {
    looped: true,
    preloadNeighbours: true,
    slideshowEffect: 'slide',
    "default": {
      styles: {
        zIndex: 1030,
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%'
      }
    },
    darkening: {
      "default": {
        attributes: {
          id: 'overlay'
        },
        styles: {
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%',
          backgroundColor: '#000'
        }
      },
      styles: {},
      opacity: 0.85
    },
    navigationButtons: {
      "default": {
        attributes: {},
        styles: {
          position: 'absolute',
          width: '50px',
          height: '100%',
          top: 0,
          cursor: 'pointer',
          color: '#FAFAFA',
          fontSize: '30px',
          fontFamily: 'Tahoma,Arial,Helvetica,sans-serif',
          textAlign: 'center',
          verticalAlign: 'middle'
        }
      },
      enabled: true,
      styles: {},
      next: {
        "default": {
          attributes: {
            id: 'navigation-right'
          },
          styles: {
            right: 0
          }
        },
        styles: {},
        text: '▶'
      },
      previous: {
        "default": {
          attributes: {
            id: 'navigation-left'
          },
          styles: {
            left: 0
          }
        },
        styles: {},
        text: '◀'
      }
    },
    closeButton: {
      "default": {
        attributes: {
          id: 'close-button'
        },
        styles: {
          position: 'absolute',
          top: 0,
          right: 0,
          color: '#FFF',
          fontSize: '30px',
          fontFamily: 'Tahoma,Arial,Helvetica,sans-serif',
          whiteSpace: 'nowrap',
          cursor: 'pointer',
          padding: '0px 20px'
        }
      },
      styles: {},
      enabled: true,
      text: '×'
    },
    image: {
      "default": {
        attributes: {
          "class": 'current'
        },
        styles: {
          cursor: 'pointer',
          maxWidth: 'none'
        }
      },
      styles: {}
    },
    bottomPanel: {
      "default": {
        attributes: {
          "class": 'bottom-panel'
        },
        styles: {
          position: 'absolute',
          bottom: 0,
          height: '70px'
        }
      },
      styles: {},
      text: {
        "default": {
          attributes: {
            "class": 'text'
          },
          styles: {
            width: '100%',
            height: '100%',
            textAlign: 'center',
            color: '#FAFAFA'
          }
        },
        styles: {}
      }
    },
    loaderTimer: void 0,
    loader: {
      "default": {
        attributes: {
          "class": 'loader'
        },
        styles: {}
      },
      styles: {},
      image: '/assets/hermitage-loader-89f127426497ac46b0284df956fabddb31aa06bd5acf4602a0a8408101752e17.gif',
      timeout: 100
    },
    minimumSize: {
      width: 100,
      height: 100
    },
    animationDuration: 400,
    images: [],
    resizeTimeout: 100,
    resizeTimer: void 0,
    init: function() {
      if ($('#hermitage').length === 0) {
        $('<div>').attr('id', 'hermitage').css(hermitage["default"].styles).hide().appendTo($('body'));
      }
      hermitage.images.length = 0;
      $.each($('a[rel="hermitage"]'), function() {
        return addImage($(this).attr('href'), $(this).attr('title'));
      });
      $('a[rel="hermitage"]').click(function(event) {
        openGallery(this);
        return event.preventDefault();
      });
      $(window).resize(function() {
        if (hermitage.resizeTimer) {
          clearTimeout(hermitage.resizeTimer);
        }
        return hermitage.resizeTimer = setTimeout(function() {
          return adjustImage(true);
        }, hermitage.resizeTimeout);
      });
      return createKeyBindings();
    }
  };

  addImage = function(source, text) {
    var image;
    image = {
      source: source,
      text: text,
      loaded: false
    };
    return hermitage.images.push(image);
  };

  indexOfImage = function(image) {
    var imageObject, img, source;
    source = $(image).prop('tagName') === 'IMG' ? $(image).attr('src') : $(image).attr('href');
    imageObject = ((function() {
      var i, len, ref, results;
      ref = hermitage.images;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        img = ref[i];
        if (img.source === source) {
          results.push(img);
        }
      }
      return results;
    })())[0];
    return hermitage.images.indexOf(imageObject);
  };

  imageAt = function(index) {
    return hermitage.images[index];
  };

  sourceFor = function(index) {
    return imageAt(index).source;
  };

  textFor = function(index) {
    return imageAt(index).text;
  };

  $.fn.applyStyles = function(params, withAnimation, complete) {
    if (complete == null) {
      complete = void 0;
    }
    if (withAnimation) {
      return this.animate(params, {
        duration: hermitage.animationDuration,
        queue: false,
        complete: complete
      });
    } else {
      return this.css(params);
    }
  };

  $.fn.center = function(withAnimation, width, height, offsetX, offsetY) {
    var params;
    if (withAnimation == null) {
      withAnimation = false;
    }
    if (width == null) {
      width = 0;
    }
    if (height == null) {
      height = 0;
    }
    if (offsetX == null) {
      offsetX = 0;
    }
    if (offsetY == null) {
      offsetY = 0;
    }
    this.css('position', 'absolute');
    if (width === 0) {
      width = $(this).outerWidth();
    }
    if (height === 0) {
      height = $(this).outerHeight();
    }
    params = {
      top: (Math.max(0, ($('#overlay').outerHeight() - height) / 2 + offsetY)) + "px",
      left: (Math.max(0, ($('#overlay').outerWidth() - width) / 2 + offsetX)) + "px"
    };
    return this.applyStyles(params, withAnimation);
  };

  $.fn.setSize = function(width, height, withAnimation) {
    var params;
    if (withAnimation == null) {
      withAnimation = false;
    }
    params = {
      width: width,
      height: height
    };
    return this.applyStyles(params, withAnimation);
  };

  $.fn.maximizeLineHeight = function(withAnimation) {
    var params;
    if (withAnimation == null) {
      withAnimation = false;
    }
    params = {
      lineHeight: (this.outerHeight()) + "px"
    };
    return this.applyStyles(params, withAnimation);
  };

  $.fn.showFromRight = function(width, height, offsetX, offsetY) {
    if (width == null) {
      width = 0;
    }
    if (height == null) {
      height = 0;
    }
    if (offsetX == null) {
      offsetX = 0;
    }
    if (offsetY == null) {
      offsetY = 0;
    }
    this.css({
      left: ($('#overlay').width()) + "px"
    });
    this.show();
    return this.center(true, width, height, offsetX, offsetY);
  };

  $.fn.showFromLeft = function(width, height, offsetX, offsetY) {
    if (width == null) {
      width = 0;
    }
    if (height == null) {
      height = 0;
    }
    if (offsetX == null) {
      offsetX = 0;
    }
    if (offsetY == null) {
      offsetY = 0;
    }
    this.css({
      left: (-$(this).outerWidth()) + "px"
    });
    this.show();
    return this.center(true, width, height, offsetX, offsetY);
  };

  $.fn.hideToRight = function(complete) {
    var params;
    if (complete == null) {
      complete = void 0;
    }
    params = {
      left: ($('#overlay').width()) + "px"
    };
    return this.applyStyles(params, true, complete);
  };

  $.fn.hideToLeft = function(complete) {
    var params;
    if (complete == null) {
      complete = void 0;
    }
    params = {
      left: (-$(this).outerWidth()) + "px"
    };
    return this.applyStyles(params, true, complete);
  };

  createElement = function(tag, params) {
    return tag.attr(params["default"].attributes).css(params["default"].styles).css(params.styles);
  };

  createDarkening = function() {
    return createElement($('<div>'), hermitage.darkening).css('opacity', hermitage.darkening.opacity).css('filter', "alpha(opacity='" + (hermitage.darkening.opacity * 100) + "')").appendTo($('#hermitage')).hide().fadeIn().click(closeGallery);
  };

  createNavigationButton = function() {
    return createElement($('<div>'), hermitage.navigationButtons).appendTo($('#hermitage')).hide().maximizeLineHeight();
  };

  createRightNavigationButton = function() {
    return createElement(createNavigationButton(), hermitage.navigationButtons.next).text(hermitage.navigationButtons.next.text).click(showNextImage);
  };

  createLeftNavigationButton = function() {
    return createElement(createNavigationButton(), hermitage.navigationButtons.previous).text(hermitage.navigationButtons.previous.text).click(showPreviousImage);
  };

  createCloseButton = function() {
    return createElement($('<div>'), hermitage.closeButton).appendTo($('#hermitage')).hide().text(hermitage.closeButton.text).click(closeGallery);
  };

  createBotomPanel = function() {
    var bottomPanel;
    bottomPanel = createElement($('<div>'), hermitage.bottomPanel).appendTo($('#hermitage')).hide();
    return createElement($('<div>'), hermitage.bottomPanel.text).appendTo(bottomPanel);
  };

  createLoader = function() {
    return loadImage(hermitage.loader.image, function() {
      return createElement($('<img>'), hermitage.loader).attr('src', hermitage.loader.image).appendTo($('#hermitage')).hide().center();
    });
  };

  clearLoaderTimer = function() {
    if (hermitage.loaderTimer) {
      return clearTimeout(hermitage.loaderTimer);
    }
  };

  showLoader = function() {
    clearLoaderTimer();
    return hermitage.loaderTimer = setTimeout(function() {
      return $('#hermitage .loader').show();
    }, hermitage.loader.timeout);
  };

  hideLoader = function() {
    clearLoaderTimer();
    return $('#hermitage .loader').hide();
  };

  createKeyBindings = function() {
    return $(document).keyup(function(e) {
      switch (e.keyCode) {
        case 27:
          return closeGallery();
        case 37:
          return showPreviousImage();
        case 39:
          return showNextImage();
      }
    });
  };

  openGallery = function(image) {
    $('#hermitage').empty().show();
    createDarkening();
    createRightNavigationButton();
    createLeftNavigationButton();
    createCloseButton();
    createBotomPanel();
    createLoader();
    return showImage(indexOfImage(image));
  };

  showImage = function(index, direction) {
    var img;
    if (direction == null) {
      direction = void 0;
    }
    showLoader();
    img = createElement($('<img />'), hermitage.image).attr('src', sourceFor(index)).hide().appendTo($('#hermitage'));
    img.click(function(event) {
      if (event.pageX >= $(window).width() / 2) {
        return showNextImage();
      } else {
        return showPreviousImage();
      }
    });
    adjustImage(false, img, direction);
    return preloadNeighboursFor(index);
  };

  showNextImage = function() {
    var current, direction, index;
    current = $('img.current');
    if (current.length === 1) {
      index = indexOfImage(current);
      if (!canShowNextAfter(index)) {
        return;
      }
      direction = hermitage.slideshowEffect === 'slide' ? 'left' : void 0;
      hideCurrentImage(direction);
      direction = hermitage.slideshowEffect === 'slide' ? 'right' : void 0;
      return showImage(nextIndexAfter(index), direction);
    }
  };

  showPreviousImage = function() {
    var current, direction, index;
    current = $('img.current');
    if (current.length === 1) {
      index = indexOfImage(current);
      if (!canShowPreviousBefore(index)) {
        return;
      }
      direction = hermitage.slideshowEffect === 'slide' ? 'right' : void 0;
      hideCurrentImage(direction);
      direction = hermitage.slideshowEffect === 'slide' ? 'left' : void 0;
      return showImage(previousIndexBefore(index), direction);
    }
  };

  hideCurrentImage = function(direction) {
    var complete, current;
    if (direction == null) {
      direction = void 0;
    }
    current = $('img.current');
    if (current.length === 1) {
      complete = function() {
        return current.remove();
      };
      if (direction === 'right') {
        return current.hideToRight(complete);
      } else if (direction === 'left') {
        return current.hideToLeft(complete);
      } else {
        return current.fadeOut(hermitage.animationDuration, complete);
      }
    }
  };

  closeGallery = function() {
    $('#hermitage :not(#overlay)').fadeOut();
    return $('#overlay').fadeOut(hermitage.animationDuration, function() {
      return $('#hermitage').hide().empty();
    });
  };

  adjustImage = function(withAnimation, image, direction) {
    var index;
    if (withAnimation == null) {
      withAnimation = false;
    }
    if (image == null) {
      image = void 0;
    }
    if (direction == null) {
      direction = void 0;
    }
    if (image === void 0) {
      image = $('#hermitage img.current');
      if (image.length !== 1) {
        return;
      }
    }
    index = indexOfImage(image);
    return loadImage(sourceFor(index), function() {
      var maxHeight, maxWidth, offsetY, scale, text;
      imageAt(index).loaded = true;
      offsetY = 0;
      maxWidth = $(window).width() - $('#navigation-left').outerWidth() - $('#navigation-right').outerWidth();
      maxHeight = $(window).height();
      text = textFor(index);
      if (text) {
        offsetY = -$('#hermitage .bottom-panel').outerHeight() / 2;
        maxHeight -= $('#hermitage .bottom-panel').outerHeight();
      }
      $('#hermitage .bottom-panel .text').text(text || '');
      if (maxWidth <= hermitage.minimumSize.width || maxHeight <= hermitage.minimumSize.height) {
        if (maxWidth < maxHeight) {
          maxWidth = hermitage.minimumSize.width;
          maxHeight = maxWidth * (this.height / this.width);
        } else {
          maxHeight = hermitage.minimumSize.height;
          maxWidth = maxHeight * (this.width / this.height);
        }
      }
      scale = 1.0;
      if (this.width > maxWidth || this.height > maxHeight) {
        scale = Math.min(maxWidth / this.width, maxHeight / this.height);
      }
      image.setSize(this.width * scale, this.height * scale, withAnimation).center(withAnimation, this.width * scale, this.height * scale, 0, offsetY);
      if (direction === 'right') {
        image.showFromRight(this.width * scale, this.height * scale, 0, offsetY);
      } else if (direction === 'left') {
        image.showFromLeft(this.width * scale, this.height * scale, 0, offsetY);
      } else {
        image.fadeIn(hermitage.animationDuration);
      }
      hideLoader();
      adjustNavigationButtons(withAnimation, image);
      adjustCloseButton(withAnimation, image);
      adjustBottomPanel(withAnimation);
      return $('#hermitage .loader').center();
    });
  };

  adjustNavigationButtons = function(withAnimation, current) {
    var currentIndex, duration, next, previous;
    if (!hermitage.navigationButtons.enabled) {
      return;
    }
    previous = $('#hermitage #navigation-left');
    next = $('#hermitage #navigation-right');
    previous.maximizeLineHeight(withAnimation);
    next.maximizeLineHeight(withAnimation);
    currentIndex = indexOfImage(current);
    duration = hermitage.animationDuration;
    if (canShowPreviousBefore(currentIndex)) {
      previous.fadeIn(duration);
    } else {
      previous.fadeOut(duration);
    }
    if (canShowNextAfter(currentIndex)) {
      return next.fadeIn(duration);
    } else {
      return next.fadeOut(duration);
    }
  };

  adjustCloseButton = function(withAnimation, current) {
    var button;
    if (!hermitage.closeButton.enabled) {
      return;
    }
    button = $('#hermitage #close-button');
    if (button.css('display') === 'none') {
      return button.fadeIn(hermitage.animationDuration);
    }
  };

  adjustBottomPanel = function(withAnimation) {
    var panel, params;
    panel = $('#hermitage .bottom-panel');
    if (panel.text() === '') {
      return panel.fadeOut(hermitage.animationDuration);
    } else {
      params = {
        width: ($(window).width() - $('#navigation-left').outerWidth() - $('#navigation-right').outerWidth()) + "px",
        left: ($('#navigation-left').position().left + $('#navigation-left').outerWidth()) + "px"
      };
      if (withAnimation) {
        panel.animate(params, {
          duration: hermitage.animationDuration,
          queue: false
        });
      } else {
        panel.css(params);
      }
      return panel.fadeIn(hermitage.animationDuration);
    }
  };

  canShowNextAfter = function(index) {
    if (hermitage.images.length < 2) {
      return false;
    }
    if (index < hermitage.images.length - 1) {
      return true;
    } else {
      return hermitage.looped;
    }
  };

  canShowPreviousBefore = function(index) {
    if (hermitage.images.length < 2) {
      return false;
    }
    if (index > 0) {
      return true;
    } else {
      return hermitage.looped;
    }
  };

  preloadNeighboursFor = function(index) {
    var nextIndex, previousIndex;
    if (!hermitage.preloadNeighbours) {
      return;
    }
    nextIndex = nextIndexAfter(index);
    previousIndex = previousIndexBefore(index);
    if (canShowNextAfter(index) && !imageAt(nextIndex).loaded) {
      loadImage(sourceFor(nextIndex), function() {
        return imageAt(nextIndex).loaded = true;
      });
    }
    if (canShowPreviousBefore(index) && !imageAt(previousIndex).loaded) {
      return loadImage(sourceFor(previousIndex), function() {
        return imageAt(previousIndex).loaded = true;
      });
    }
  };

  loadImage = function(source, complete) {
    return $('<img />').attr('src', source).load(complete);
  };

  nextIndexAfter = function(index) {
    if (index < hermitage.images.length - 1) {
      return index + 1;
    } else {
      return 0;
    }
  };

  previousIndexBefore = function(index) {
    if (index > 0) {
      return index - 1;
    } else {
      return hermitage.images.length - 1;
    }
  };

  $(document).ready(hermitage.init);

  $(document).on('page:change', hermitage.init);

}).call(this);
