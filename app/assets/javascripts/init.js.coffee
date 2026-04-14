#= require namespace
App.init = ->
  App.remoteSelectLoad.init()
  # Bootstrap 5: use the global bootstrap object exposed by application.js (esbuild)
  document.querySelectorAll('abbr[title]').forEach (el) ->
    new window.bootstrap.Tooltip(el)
  $(document).on 'click', '.jCheckAll', (e) ->
    id = $(this).attr('id')
    checked = $(this).prop('checked')
    $('input.' + id).prop('checked', checked)
  # fix select2 open focus behavior
  $(document).on 'select2:open', (e) =>
    selectId = e.target.id
    $(".select2-search__field[aria-controls='select2-" + selectId + "-results']").each (key, value) ->
        value.focus();
  # BS4 button group toggle (data-bs-toggle="buttons") — Bootstrap 5 removed this jQuery plugin
  $(document).on 'change', '[data-bs-toggle="buttons"] input[type="radio"]', (e) ->
    $btn = $(e.target).closest('.btn')
    $btn.closest('[data-bs-toggle="buttons"]').find('.btn').removeClass('active')
    $btn.addClass('active')
  $(document).on 'change', '[data-bs-toggle="buttons"] input[type="checkbox"]', (e) ->
    $btn = $(e.target).closest('.btn')
    if $(e.target).prop('checked')
      $btn.addClass('active')
    else
      $btn.removeClass('active')

  return true

# TODO may also need to do on pjax_modal change
$ ->
  App.init()
