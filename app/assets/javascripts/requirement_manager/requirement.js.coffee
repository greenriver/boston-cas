#= require ./namespace

class App.RequirementManager.Requirement
  # basic model class that holds the data for a requirement
  
  constructor: (attrs) ->
    # oooo, object destructuring assignment :-d
    {@id, @rule_id, @rule_name, @positive, @variable, @display_for_variable} = attrs
    @must_active = 'active' if @positive
    @cant_active = 'active' unless @positive
    if @positive
      @positive_string = '1'
    else
      @positive_string = '0'
    

  @from_element: (element) =>
    rule_id = $(element).attr('data-requirement-rule-id')

    attrs = 
      id: $(element).attr('data-requirement-id')
      rule_id: rule_id
      rule_name: $(element).attr('data-requirement-rule-name')
      positive: $(element).attr('data-requirement-positive') == 'true'
      variable: $(element).attr('data-requirement-variable')
      display_for_variable: $(element).attr('data-requirement-display-for-variable')
    new @(attrs)
    
  # use rule_id as our index in stores since we might not have an
  # id of our own
  store_key: -> @rule_id
  
  to_rule: -> new App.RequirementManager.Rule id: @rule_id, name: @rule_name