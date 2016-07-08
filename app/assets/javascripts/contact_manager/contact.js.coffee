#= require ./namespace

class App.ContactManager.Contact
  # basic model class that holds the data for a contact
  
  constructor: (attrs) ->
    # oooo, object destructuring assignment :-d
    {@id, @name, @email, @phone} = attrs

  @from_element: (element) =>
    attrs = 
      id: $(element).data('contact-id')
      name: $(element).data('contact-name')
      email: $(element).data('contact-email')
      phone: $(element).data('contact-phone')
    new @(attrs)