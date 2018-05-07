#= require ./namespace

class App.Matches.ActionNav
  constructor: (@element) ->
    @addListeners()

  changeTab: (event) ->
    tabData = $(event.currentTarget).data()
    $title = $(@element).find('.jMatchActionTitle')
    $icon = $(@element).find('.jMatchActionIcon')
    $icon.removeClass().addClass("jMatchActionIcon c-choice-icon c-choice-icon--#{tabData.type}")
    $title.text(tabData.title)
    console.log $title, $icon, @element

  addListeners: ->
    $(@element).on('click', '.nav-link', @changeTab.bind(@))
