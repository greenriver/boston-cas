<% if @help.errors.any? %>
  $('.help-form').html "<%=j render 'form' %>"
  $('.jSwitcher').trigger('change');
<% else %>
  #window.ajaxModalInstance.closeModal()
  $('#ajax-modal').modal('hide')
  #window.location.reload()
<% end %>