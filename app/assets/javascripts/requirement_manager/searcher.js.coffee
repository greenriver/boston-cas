#= require ./namespace

# see notes on contact manager searcher performance
# in app/assets/javascripts/contact_manager/searcher.js.coffee
#
# the same considerations are applicable here if we get a large number of rules
#
# ~ @rrosen 4/22/2016

class App.RequirementManager.Searcher
  constructor: (@element, opts) ->
    @controller = opts.controller
    @available_rules = @controller.available_rules
    @placeholder = $(@element).attr 'placeholder'
    @_init_select2()
    @_init_select_listener()

  _init_select2: ->
    $(@element).select2
      theme: 'bootstrap'
      data: @_select2_data()
      placeholder: @placeholder
      width: '100%'
      dropdownParent: $(@element).closest('form')

  _init_select_listener: ->
    $(".jVariableRequirment").hide()
    $(@element).on 'select2:select', (e) =>
      rule_id = $(@element).val()
      $(".jVariableRequirment").hide()
      $(".jVariableRequirment[data-rule-id=#{rule_id}]").show()
      $(".jVariableRequirment[data-rule-id=#{rule_id}] select").css('width', '100%')
      $(".jVariableRequirment[data-rule-id=#{rule_id}] select").select2()

  reset: ->
    # resetting select2 this way currently throws
    # Uncaught TypeError: Cannot read property 'current' of null
    # on subsequent choices
    # doesn't seem to break anything though
    $(@element).val("")
    $(@element).select2 'destroy'
    $(@element).find('option').remove()
    @_init_select2()

  _select2_data: ->
    result = [{id: "", text: ""}]
    result = result.concat @available_rules.map (rule) => {text: rule.name, id: rule.id}
    result.sort(@_compare_rules)

  _compare_rules: (a, b) ->
    if a.text < b.text
      return -1
    if a.text > b.text
      return 1
    return 0
