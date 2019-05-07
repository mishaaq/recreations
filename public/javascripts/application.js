$(document).ready(function () {
  $('#login-modal').modal({
    backdrop: 'static',
    keyboard: false
  });
  $('[data-toggle="popover"]').popover();

  $('button[type="submit"]').click(function() {
    $('#login_form').submit();
  });
  $('input').keydown(function (event) {
    var keyPressed = event.keyCode || event.which;
    if (keyPressed === 13) {
      $('#login_form').submit();
    }
  })
});