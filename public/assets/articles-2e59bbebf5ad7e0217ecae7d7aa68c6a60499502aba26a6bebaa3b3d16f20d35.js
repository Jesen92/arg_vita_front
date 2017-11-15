(function() {
  $('.infinite-table').infinitePages({
    debug: true,
    buffer: 200,
    context: '.pane',
    loading: function() {
      return $(this).text("Loading...");
    },
    success: function() {},
    error: function() {
      return $(this).text("Trouble! Please drink some coconut water and click again");
    }
  }, $(function() {}), $('.infinite-table').infinitePages({
    loading: function() {
      return $(this).text('Loading next page...');
    },
    error: function() {
      return $(this).button('There was an error, please try again');
    }
  }));

}).call(this);
