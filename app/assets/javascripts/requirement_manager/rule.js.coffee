#= require ./namespace

class App.RequirementManager.Rule
  # basic model class that holds the data for a rule
  
  constructor: (attrs) ->
    # oooo, object destructuring assignment :-d
    {@id, @name} = attrs

  @from_element: (element) =>
    attrs = 
      id: $(element).data('rule-id')
      name: $(element).data('rule-name')
    new @(attrs)
    
  store_key: -> @id