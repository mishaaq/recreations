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
  }).on('click', function (event) {
    $('[data-toggle="popover"]').each(function () {
      //the 'is' for buttons that trigger popups
      //the 'has' for icons within a button that triggers a popup
      if (!$(this).is(event.target) &&
          $(this).has(event.target).length === 0 &&
          $(this).next('.popover').length !== 0 &&
          $(this).next('.popover').has(event.target).length === 0) {
        (($(this).popover('hide').data('bs.popover')||{}).inState||{}).click = false  // fix for BS 3.3.6
      }
    });
  }).on('click', '.dropdown-menu a[data-control="menu-settings"]', function (event) {
    event.stopPropagation();
  });

  $('input[name="spark-integration"]').on('change', function (event) {
    var value = $(event.target).is(':checked');
    value =
    $.ajax({
      url: '/user/update',
      method: 'put',
      data: "spark_integration={0}&authenticity_token={1}".format(value, CSRF)
    });
  });

  $('[data-control="user-name"]').popover({
    content: function () {
      var userDisplayName = $(this).attr('data-user-display-name');
      var userEmail = $(this).attr('data-user-email');
      return $("#user-form-template").html().format(userDisplayName, userEmail);
    }
  }).on('shown.bs.popover', function (event) {
    $(this).next('.popover').find('input:first').focus();
  }).on('hide.bs.popover', function (event) {
    var $this = $(this);
    var form = $this.next('.popover').find('form');
    $.ajax({
      url: form.attr('action'),
      method: form.attr('method'),
      dataType: "json",
      data: form.serialize(),
      async: false,
      context: {
        elem: $this,
        form: form
      },
      success: function (response) {
        this.elem.text(response['display_name'])
          .attr('data-user-display-name', response['display_name'])
          .attr('data-user-email', response['email']);
      },
      error: function (response) {
        var form = this.form;
        event.preventDefault();
        var errors = response.responseJSON;
        $.each(errors, function (fieldName) {
          form.find("input[name='{0}']".format(fieldName)).next('.help-block').text(errors[fieldName].join()).parent().addClass('has-error');
        });
      }
    });
  });

  $('[data-control="reserve-action-icon-menu"]').popover({
    content: function() {
      var href = $(this).attr('data-control-href');
      return $('#reservation-action-menu-template').html().format(href)
    }
  });

});