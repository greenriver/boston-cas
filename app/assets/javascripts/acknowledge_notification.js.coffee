#= require namespace
App.acknowledge_notification = (href) ->
  console.log 'acknowledging!'
  $.ajax href,
    method: 'post'
    success: ( -> window.location.reload(true) )
    error: (-> alert 'Sorry, an error occurred.  Please contact DND.')
    dataType: 'html'