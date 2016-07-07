#= require ./namespace

class App.ContactManager.ContactStore
  constructor: ->
    @_store = {}
    
  # all: ->
  #   result = []
  #   result.push value for own key, value of @_store
  #   result
  
  find: (id) ->
    @_store[id]
    
  remove: (id) ->
    delete @_store[id]
      
  add: (contact) ->
    @_store[contact.id] = contact
  
  map: (fn) ->
    fn.call(@, value) for own key, value of @_store