#= require ./namespace

# This class represents the button that adds a new
# requirement after it's been selected from the list

class App.RequirementManager.AddButton
  constructor: (@element, opts) ->
    @controller = opts.controller
    @_add_on_click()
    
  _add_on_click: ->
    $(@element).on 'click', (evt) =>
      evt.preventDefault()
      @controller.add_requirement_from_rule_searcher()
      $(".jVariableRequirment").hide()