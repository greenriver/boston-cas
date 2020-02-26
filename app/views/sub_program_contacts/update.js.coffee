<% if @program_contacts.errors.any? %>
  #display errors
  $('form.jContactForm .alert.alert-danger .jContactFormErrors').remove()
  $('form.jContactForm').prepend('<div class="alert alert-danger jContactFormErrors"><%= @program_contacts.errors.full_messages.join(', ') %></div>')
<% else %>
  html = "<%= j render 'form' %>"
  $('.jContactForm').replaceWith(html)
  $('.select2').select2()
<% end %>
