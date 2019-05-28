<% if @client_contacts.errors.any? %>
  $('form.jContactForm .alert.alert-danger .jContactFormErrors').remove()
  $('form.jContactForm').prepend('<div class="alert alert-danger jContactFormErrors"><%= @client_contacts.errors.full_messages.join(', ') %></div>')
<% else %>
  html = "<%= j render 'form' %>"
  $('.jContactForm').replaceWith(html)
  $('.select2').select2()
<% end %>