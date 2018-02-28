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

  function detectPrivateMode(cb) {
    var db,
      on = cb.bind(null, true),
      off = cb.bind(null, false);

    function tryls() {
      try {
        localStorage.length ? off() : (localStorage.x = 1, localStorage.removeItem("x"), off());
      } catch (e) {
        // Safari only enables cookie in private mode
        // if cookie is disabled then all client side storage is disabled
        // if all client side storage is disabled, then there is no point
        // in using private mode
        navigator.cookieEnabled ? on() : off();
      }
    }

    // Blink (chrome & opera)
    window.webkitRequestFileSystem ? webkitRequestFileSystem(0, 0, off, on)
      // FF
      : "MozAppearance" in document.documentElement.style ? (db = indexedDB.open("test"), db.onerror = on, db.onsuccess = off)
      // Safari
      : /constructor/i.test(window.HTMLElement) || window.safari ? tryls()
        // IE10+ & edge
        : !window.indexedDB && (window.PointerEvent || window.MSPointerEvent) ? on()
          // Rest
          : off()
  }

  var $root = $('html, body');

  detectPrivateMode(function (isPrivateMode) {
    if (isPrivateMode) {
      $root.children().replaceWith("<html><p>Private mode not supported.</p></html>");
    }
  });

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