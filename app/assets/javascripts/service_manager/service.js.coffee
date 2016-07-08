#= require ./namespace

class App.ServiceManager.Service
  # basic model class that holds the data for a service
  
  constructor: (attrs) ->
    # oooo, object destructuring assignment :-d
    {@id, @name, @requirements_description} = attrs

  @from_element: (element) =>
    attrs = 
      id: $(element).data('service-id')
      name: $(element).data('service-name')
      requirements_description: $(element).data('service-requirements-description')
    new @(attrs)
    
  store_key: -> @id