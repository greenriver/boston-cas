#= require ./namespace

# Note, we're using select2 here.  It's not ideal for our purposes
# (or at least my use of it isn't), because we're dealing with largish lists of
# available contacts (~1000 at dev time) and the list of available
# contacts changes every time we select or remove one.  This results in the
# page UI freezing for a few seconds.  The freeze seems to be associated with
# a lot of DOM rebuild when we reinitialize select2 (there's probably an
# <option> tag for each contact).
#
# Unfortunately, as of this writing, the landscape of jquery / raw-js
# autocomplete plugins is pretty depressing.  Most of the other libraries
# are looking for new maintainers.  If we do want to nix this
# performance issue at some point, and are looking for a different library
# there are two features that are important:
#
# 1.  Separation of labels from values (we want to autocomplete on a name
#     but be able to pass an id to our code)
#
# 2.  Ability to programatically add and remove options from the available list #    without completely having to completely reset the widget.
#
# Select2 does #1, but not #2.  Twitter's typeahead.js might be flexible enough
# to able to do both, but neither are first-class use cases in the
# documentation.  Plus typeahead hasn't been updated in a year and is looking 
# for new maintainers.
#
# A React shadow-dom solution might also be a good way to solve this problem.
# But I've already sunk too much time into this task and we have a lot of 
# other features to get ready for MVP.
# The pause is not too awful and I've got "working..." indicators to assure
# the user that yes, their action is doing something.
#
# ~ @rrosen 4/22/2016

class App.ContactManager.Searcher
  constructor: (@element, opts) ->
    @controller = opts.controller
    @available_contacts = @controller.available_contacts
    @_init_select2()
    @_init_select_listener()
    
  _init_select2: ->
    $(@element).select2
      theme: 'bootstrap'
      data: @available_contacts.map (contact) => {text: "#{contact.name} <#{contact.email}>", id: contact.id}
      prompt: $(@element).attr 'prompt'
    # fix select2 container width in modals
    $('.select2-container').attr 'style', 'width: 100%;'
  
  _init_select_listener: ->
    $(@element).on 'change', (evt) =>
      @controller.show_loading_spinner =>
        contact_id = Number $(evt.target).val()
        selected_contact = @available_contacts.find contact_id
        @available_contacts.remove contact_id
        @reset()
        @controller.select_contact selected_contact
        @controller.hide_loading_spinner()
  
  reset: ->
    # resetting select2 this way currently throws
    # Uncaught TypeError: Cannot read property 'current' of null
    # on subsequent choices
    # doesn't seem to break anything though
    $(@element).val("")
    $(@element).select2 'destroy'
    @_init_select2()