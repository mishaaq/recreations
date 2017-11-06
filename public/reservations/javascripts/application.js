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
  $('[data-control="display-name"]').editable({
    params: {
      authenticity_token: CSRF
    }
  });
});