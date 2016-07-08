#= require ./namespace

class App.ServiceManager.ServiceRow
  constructor: (@service, opts) ->
    @controller = opts.controller
    @input_name = "#{@controller.base_object_name}[service_ids][]"
  
  to_html: ->
    HandlebarsTemplates['service_manager/service_row']
      input_name: @input_name
      service: @service