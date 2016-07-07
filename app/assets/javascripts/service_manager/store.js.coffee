#= require ./namespace

# A hash of requirements or rules by id
class App.ServiceManager.Store
  constructor: ->
    @_store = {}
  
  find: (id) ->
    @_store[id]
    
  remove: (id) ->
    delete @_store[id]
      
  add: (obj) ->
    @_store[obj.store_key()] = obj
  
  map: (fn) ->
    fn.call(@, value) for own key, value of @_store