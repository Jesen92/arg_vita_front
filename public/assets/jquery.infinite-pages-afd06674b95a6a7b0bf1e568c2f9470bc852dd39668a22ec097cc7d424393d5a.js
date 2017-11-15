
/*
jQuery Infinite Pages v0.2.0
https://github.com/magoosh/jquery-infinite-pages

Released under the MIT License
 */

(function() {
  var slice = [].slice;

  (function($, window) {
    var InfinitePages;
    InfinitePages = (function() {
      InfinitePages.prototype.defaults = {
        debug: false,
        navSelector: 'a[rel=next]',
        buffer: 1000,
        loading: null,
        success: null,
        error: null,
        context: window,
        state: {
          paused: false,
          loading: false
        }
      };

      function InfinitePages(container, options) {
        this.options = $.extend({}, this.defaults, options);
        this.$container = $(container);
        this.$table = $(container).find('table');
        this.$context = $(this.options.context);
        this.init();
      }

      InfinitePages.prototype.init = function() {
        var scrollHandler, scrollTimeout;
        scrollTimeout = null;
        scrollHandler = ((function(_this) {
          return function() {
            return _this.check();
          };
        })(this));
        return this.$context.scroll(function() {
          if (scrollTimeout) {
            clearTimeout(scrollTimeout);
            scrollTimeout = null;
          }
          return scrollTimeout = setTimeout(scrollHandler, 250);
        });
      };

      InfinitePages.prototype._log = function(msg) {
        if (this.options.debug) {
          return typeof console !== "undefined" && console !== null ? console.log(msg) : void 0;
        }
      };

      InfinitePages.prototype.check = function() {
        var distance, nav, windowBottom;
        nav = this.$container.find(this.options.navSelector);
        if (nav.size() === 0) {
          return this._log("No more pages to load");
        } else {
          windowBottom = this.$context.scrollTop() + this.$context.height();
          distance = nav.offset().top - windowBottom;
          if (this.options.state.paused) {
            return this._log("Paused");
          } else if (this.options.state.loading) {
            return this._log("Waiting...");
          } else if (distance > this.options.buffer) {
            return this._log((distance - this.options.buffer) + "px remaining...");
          } else {
            return this.next();
          }
        }
      };

      InfinitePages.prototype.next = function() {
        if (this.options.state.done) {
          return this._log("Loaded all pages");
        } else {
          this._loading();
          return $.getScript(this.$container.find(this.options.navSelector).attr('href')).done((function(_this) {
            return function() {
              return _this._success();
            };
          })(this)).fail((function(_this) {
            return function() {
              return _this._error();
            };
          })(this));
        }
      };

      InfinitePages.prototype._loading = function() {
        this.options.state.loading = true;
        this._log("Loading next page...");
        if (typeof this.options.loading === 'function') {
          return this.$container.find(this.options.navSelector).each(this.options.loading);
        }
      };

      InfinitePages.prototype._success = function() {
        this.options.state.loading = false;
        this._log("New page loaded!");
        if (typeof this.options.success === 'function') {
          return this.$container.find(this.options.navSelector).each(this.options.success);
        }
      };

      InfinitePages.prototype._error = function() {
        this.options.state.loading = false;
        this._log("Error loading new page :(");
        if (typeof this.options.error === 'function') {
          return this.$container.find(this.options.navSelector).each(this.options.error);
        }
      };

      InfinitePages.prototype.pause = function() {
        this.options.state.paused = true;
        return this._log("Scroll checks paused");
      };

      InfinitePages.prototype.resume = function() {
        this.options.state.paused = false;
        this._log("Scroll checks resumed");
        return this.check();
      };

      return InfinitePages;

    })();
    return $.fn.extend({
      infinitePages: function() {
        var args, option;
        option = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        return this.each(function() {
          var $this, data;
          $this = $(this);
          data = $this.data('infinitepages');
          if (!data) {
            $this.data('infinitepages', (data = new InfinitePages(this, option)));
          }
          if (typeof option === 'string') {
            return data[option].apply(data, args);
          }
        });
      }
    });
  })(window.jQuery, window);

}).call(this);
