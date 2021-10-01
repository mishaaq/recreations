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

  $(document).on('click', function (event) {
    $('[data-toggle="popover"]').each(function () {
      //the 'is' for buttons that trigger popups
      //the 'has' for icons within a button that triggers a popup
      if (!$(this).is(event.target) &&
        $(this).has(event.target).length === 0 &&
        $(this).next('.popover').length !== 0 &&
        $(this).next('.popover').has(event.target).length === 0) {
        (($(this).popover('hide').data('bs.popover') || {}).inState || {}).click = false  // fix for BS 3.3.6
      }
    });
  });

  $('[data-control="date-filter"]').popover({
    title: 'Show at',
    content: function () {
      var filterDate = filter['date'];
      return $("#date-filter-datepicker-template").html().format(filterDate);
    }
  }).on('shown.bs.popover', function (event) {
    var datepicker = $(this).next('.popover').find('[data-control="date-filter-datepicker"]');
    datepicker.datepicker({clearBtn: true}).on('changeDate', function(event) {
      var searchParams = new URLSearchParams(location.search);
      searchParams.set("filter_date", datepicker.datepicker('getFormattedDate'));
      location.search = searchParams.toString();
    }).on('clearDate', function() {
      var searchParams = new URLSearchParams(location.search);
      searchParams.set("filter_date", "");
      location.search = searchParams.toString();
    });
  });

  $.get('users.json', function (data) {
    var users = data;
    $('[data-control="user-filter"]').popover({
      title: 'Show for',
      content: function () {
        var filterUser = filter['user'];
        return $("#user-filter-typeahead-template").html().format(filterUser);
      }
    }).on('shown.bs.popover', function (event) {
      var typeahead = $(this).next('.popover').find('[data-control="user-filter-typeahead"]');
      typeahead.typeahead({
        source: users,
        autoSelect: true,
        displayText: function(item) {
          return "{0} ({1})".format(item.name, item.display_name);
        },
        afterSelect: function(item) {
          var searchParams = new URLSearchParams(location.search);
          if (item) {
            searchParams.set("filter_user", item.id);
          } else {
            searchParams.delete("filter_user");
          }
          location.search = searchParams.toString();
        }
      });
    });
  }, 'json');
});

!function($) {
  'use strict';

  $(function() {
    function toggleAction(selector, disabled) {
      var method = disabled ? 'addClass' : 'removeClass';
      $(selector)[method]('list-menu-link-disabled').parent()[method]('list-menu-wrapper-disabled');
    }
    // Check/uncheck all functionality
    function checkAll(base, checked) {
      // Toggle all checkboxes on the table's body that exist on the first column.
      base.find(listCheckboxesSelector).prop('checked', checked);
      base.find('.list-row')[checked ? 'addClass' : 'removeClass']('list-row-selected');
      toggleAction('#delete-selected', !checked);
    }
    function generalToggle() {
      var checked = listCheckboxes.filter(':checked').length;
      toggleAction('#delete-selected', checked === 0);
      toggleAction('#merge-selected', checked < 2);
      toggleAction('#deselect-all', checked === 0);
      toggleAction('#select-all', checked === listCheckboxesLength);
    }

    var listCheckboxesSelector = '.list-selectable-checkbox', list = $('#list'), alertTimeout = 4000, listCheckboxes, listCheckboxesLength;

    // Automatically close alerts if there was any present.
    if ($('.alert').length > 0) {
      setTimeout(function() { $('.alert').alert('close'); }, alertTimeout);
    }

    // Only process list-related JavaScript if there's a list!
    if (list.length > 0) {
      listCheckboxes = list.find(listCheckboxesSelector);
      listCheckboxesLength = listCheckboxes.length;
      
      // Confirm before deleting one item
      $('.list-row-action-delete-one').on('click', function(ev) {
        ev.preventDefault();
        $(this).addClass('list-row-action-wrapper-link-active')
          .siblings('.list-row-action-popover-delete-one').first().show()
          .find('.cancel').on('click', function() {

            $(this).parents('.list-row-action-popover-delete-one').hide()
              .siblings('.list-row-action-delete-one').removeClass('list-row-action-wrapper-link-active');
          });
      });

      // Select/deselect record on row's click
      list.find('.list-row').on('click', function(ev) {
        var checkbox, willBeChecked;
        ev.stopPropagation();

        if (ev.currentTarget.tagName === 'TR') {
          checkbox = $(this).find('.list-selectable-checkbox');
          willBeChecked = !checkbox.prop('checked');
          checkbox.prop('checked', willBeChecked);
          $(this)[willBeChecked ? 'addClass' : 'removeClass']('list-row-selected');
          generalToggle();
        }
      });
      // Select all action 
      $('#select-all').on('click', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        if ($(this).is('.list-menu-link-disabled')) return;

        // We assume we want to stay on the dropdown to delete all perhaps
        ev.stopPropagation();
        checkAll(list, true);
        toggleAction('#select-all', true);
        toggleAction('#deselect-all', false);
      });
      // Deselect all action 
      $('#deselect-all').on('click', function(ev) {
        ev.preventDefault();
        if ($(this).is('.list-menu-link-disabled')) return;

        checkAll(list, false);
        toggleAction('#deselect-all', true);
        toggleAction('#select-all', false);
      });
      // Delete selected
      $('#delete-selected').on('click', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        if ($(this).is('.list-menu-link-disabled')) return;

        // Open the popup to confirm deletion
        $(this).parent().addClass('active').parent('.dropdown').addClass('open');
        $(this).addClass('active')
          .siblings('.list-menu-popover-delete-selected').first().show()
          .find('.cancel').on('click', function() {
          
            // Hide the popover on cancel
            $(this).parents('.list-menu-popover-delete-selected').hide()
              .siblings('#delete-selected').removeClass('active').parent().removeClass('active');
            // and close the dropdown
            $(this).parents('.dropdown').removeClass('open');
          });

        $(this).siblings('.list-menu-popover-delete-selected').find(':hidden[data-delete-many-ids=true]').
          val(listCheckboxes.filter(':checked').map(function() { return $(this).val(); }).toArray().join(','));
      });
      // Delete selected
      $('#merge-selected').on('click', function(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        if ($(this).is('.list-menu-link-disabled')) return;

        // Open the popup to confirm deletion
        $(this).parent().addClass('active').parent('.dropdown').addClass('open');
        $(this).addClass('active')
          .siblings('.list-menu-popover-merge-selected').first().show()
          .find('.cancel').on('click', function() {

          // Hide the popover on cancel
          $(this).parents('.list-menu-popover-merge-selected').hide()
            .siblings('#merge-selected').removeClass('active').parent().removeClass('active');
          // and close the dropdown
          $(this).parents('.dropdown').removeClass('open');
        });

        $(this).siblings('.list-menu-popover-merge-selected').find(':hidden[data-merge-many-ids=true]').
        val(listCheckboxes.filter(':checked').map(function() { return $(this).val(); }).toArray().join(','));
      });

      // Catch checkboxes check/uncheck and enable/disable the delete selected functionality
      listCheckboxes.on('click', function(ev) {
        ev.stopPropagation();

        $(this).parent('.list-row')[$(this).is(':checked') ? 'addClass' : 'removeClass']('list-row-selected');

        generalToggle();
      });
    }

    // Autofocus first field with an error. (usability)
    var error_input;
    if (error_input = $('.has-error :input').first()) { error_input.focus(); }
  });
}(window.jQuery);
