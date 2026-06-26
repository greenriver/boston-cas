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

  _dropdownParent: (element) ->
    # .modal-body has overflow-y:auto in Bootstrap 5 scrollable modals, which clips
    # the dropdown. Use .modal-content (above the clip boundary) when inside a modal.
    $modalContent = $(element).closest('.modal-content')
    if $modalContent.length then $modalContent else $(element).closest('form')

  _init_select2: ->
    $(@element).select2
      theme: 'bootstrap'
      data: @_select2_data()
      placeholder: @placeholder
      width: '100%'
      dropdownParent: @_dropdownParent(@element)

  _init_select_listener: ->
    $mgr = $(@controller.element)
    $mgr.find(".jVariableRequirment").hide()
    $mgr.find(".jRuleSelectionNote").hide()
    $(@element).on 'select2:select', (e) =>
      rule_id = $(@element).val()
      $mgr.find(".jVariableRequirment").hide()
      $mgr.find(".jRuleSelectionNote").hide()
      $mgr.find(".jVariableRequirment[data-rule-id=#{rule_id}]").show()
      $variableSelect = $mgr.find(".jVariableRequirment[data-rule-id=#{rule_id}] select")
      $variableSelect.css('width', '100%')
      $variableSelect.select2
        dropdownParent: @_dropdownParent($variableSelect[0])
      $mgr.find(".jRuleSelectionNote[data-rule-id=#{rule_id}]").show()

      # Auto-add for non-variable rules when positivity is already chosen
      chosen_rule = @available_rules.find(Number(rule_id))
      positivity = @controller.new_requirement_positive_value
      if chosen_rule && !chosen_rule.variable && (positivity == true || positivity == false)
        @controller.add_requirement_from_rule_searcher()
        $mgr.find(".jVariableRequirment").hide()

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
