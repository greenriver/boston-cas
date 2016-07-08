#= require ./namespace

# This class represents the Must/Cant Buttons that decide the "postive"
# attribute of newly added requirements

class App.RequirementManager.NewRequirementPositivityToggle
  constructor: (@element, opts) ->
    @controller = opts.controller
    @requirement_positive = Boolean $(@element).data('requirement-positive')
    @_select_positivity_on_click()
    
  _select_positivity_on_click: ->
    $(@element).on 'click', (evt) =>
      evt.preventDefault()
      @controller.select_new_requirement_positivity @requirement_positive

  setActive: ->
    $(@element).addClass 'active'
  
  removeActive: ->
    $(@element).removeClass 'active'
