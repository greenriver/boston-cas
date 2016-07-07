# enhances submit buttons to add a custom param to the submitted form
#= require namespace
class App.EnhancedSubmitParam
  constructor: (@element) ->
    @name = $(@element).attr 'data-submit-param-name'
    @value = $(@element).attr 'data-submit-param-value'
    @_register_listener()
  
  _register_listener: ->
    $(@element).on 'click', (evt) =>
      form = evt.target.form
      $(form).append "<input type=\"hidden\" name=\"#{@name}\" value=\"#{@value}\"></input>"
      
$('[data-submit-param-name][data-submit-param-value]').each (_i, element) ->
  new App.EnhancedSubmitParam element