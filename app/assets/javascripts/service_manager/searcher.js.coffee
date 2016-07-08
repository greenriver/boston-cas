#= require ./namespace

class App.ServiceManager.Searcher
  constructor: (@element, opts) ->
    @controller = opts.controller
    @available_services = @controller.available_services
    @placeholder = "Start typing name or select from list."
    @_init_select2()
    @_init_select_listener()
    
  _init_select2: ->
    $(@element).select2
      theme: 'bootstrap'
      data: @_select2_data()
      placeholder: @placeholder
      allowClear: true
    # fix select2 container width in modals
    $('.select2-container').attr 'style', 'width: 100%;'
  
  _init_select_listener: ->
    $(@element).on 'change', (evt) =>
      @controller.show_loading_spinner =>
        service_id = Number $(evt.target).val()
        selected_service = @available_services.find service_id
        @available_services.remove service_id
        @reset()
        @controller.select_service selected_service
        @controller.hide_loading_spinner()
  
  reset: ->
    $(@element).val("")
    $(@element).select2 'destroy'
    $(@element).find('option').remove()
    @_init_select2()
  
  _select2_data: ->
    result = [{id: "", text: ""}]
    result = result.concat @available_services.map (service) => {text: "#{service.name}", id: service.id}
    result.sort(@_compare_services)

  _compare_services: (a, b) ->
    if a.text < b.text
      return -1
    if a.text > b.text
      return 1
    return 0