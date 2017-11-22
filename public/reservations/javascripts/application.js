if (!String.prototype.format) {
  String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) {
      return typeof args[number] !== 'undefined'
        ? args[number]
        : match
        ;
    });
  };
}

$(document).ready(function () {

  var $root = $('html, body');

  $(document).on('click', '.navbar-nav a[href^="#"]', function (event) {
    event.preventDefault();

    var href = $.attr(this, 'href');

    $root.animate({
      scrollTop: $(href).offset().top
    }, 500, function () {
      window.location.hash = href;
    });

    return false;
  });

  $.fn.editable.defaults.ajaxOptions = {type: "put"};
  $('[data-control="user-name"]').editable({
    params: {
      authenticity_token: CSRF
    }
  });

  $('[data-control="reserve-action-icon-menu"]').popover({
    content: function() {
      var href = $(this).attr('data-control-href');
      return '<span data-control="reserve-action-menu" style="white-space: nowrap">\
        <a href="{0}" class="btn btn-link"><span class="glyphicon glyphicon-calendar"></span>Add to Calendar</a>\
        <span class="vertical-divider"></span>\
        <button type="submit" class="btn btn-link"><span class="glyphicon glyphicon-remove"></span>Cancel</button>\
        </span>'.format(href)
    }
  });

});