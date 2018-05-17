#= require ./namespace

class App.Matches.Decline
  constructor: (@trigger, @note) ->
    @trigger.on 'change', =>
      if @trigger.filter(':checked').length > 0 || @note.hasClass('error')
        @note.show()
      else
        @note.hide()
    @trigger.trigger('change')
