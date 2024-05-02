#= require namespace
App.init = ->
  App.remoteSelectLoad.init()
  $('abbr').tooltip();
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();
  $.fn.datepicker.defaults.format = "M d, yyyy";
  $(document).on 'click', '.jCheckAll', (e) ->
    id = $(this).attr('id')
    checked = $(this).prop('checked')
    $('input.' + id).prop('checked', checked)
  # fix select2 open focus behavior
  $(document).on 'select2:open', (e) =>
    selectId = e.target.id
    $(".select2-search__field[aria-controls='select2-" + selectId + "-results']").each (key, value) ->
        value.focus();

  return true

# TODO may also need to do on pjax_modal change
$ ->
  App.init()
  $('.datepicker.enable-on-load, .date_picker.enable-on-load')
    .prop('disabled', false)
    .datepicker()
