<% if @match_contacts.errors.any? %>
  $('form.jContactForm .alert.alert-danger .jContactFormErrors').remove()
  $('form.jContactForm').prepend('<div class="alert alert-danger jContactFormErrors"><%= @program_contacts.errors.full_messages.join(', ') %></div>')
<% else %>
  html = "<%= j render 'form' %>"
  $('.jContactForm').replaceWith(html)
  
  html = "<%= j render 'matches/match_contacts_form' %>"
  $('.jDnDStaffContactForm').replaceWith(html)
  
  html = "<%= j render 'match_contacts/match_contacts_list', match: @match_contacts.match %>"
  $('.jMatchContactList').replaceWith(html)
<% end %>
