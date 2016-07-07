#= require ./namespace

class App.ContactManager.ContactRow
  constructor: (@contact, opts) ->
    @controller = opts.controller
    @input_name_prefix = "#{@controller.base_object_name}[#{@controller.contacts_type}_contact_ids]"
  
  to_html: ->
    HandlebarsTemplates['contact_manager/contact_row']
      input_name_prefix: @input_name_prefix
      contact: @contact