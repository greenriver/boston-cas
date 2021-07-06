#= require ./namespace

class App.RequirementManager.RequirementRow
  constructor: (@requirement, opts) ->
    @controller = opts.controller
    @input_name_prefix = "#{@controller.base_object_name}[requirements_attributes][#{opts.index}]"

  to_html: ->
    HandlebarsTemplates['requirement_manager/requirement_row']
      input_name_prefix: @input_name_prefix
      requirement: @requirement
