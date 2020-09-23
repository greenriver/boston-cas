<% if @help.errors.any? %>
  $('.help-form').html "<%=j render 'form' %>"
  $('.jSwitcher').trigger('change');
<% else %>
  #window.pjax_modal_instance.closeModal()
  $('#pjax-modal').modal('hide')
  #window.location.reload()
<% end %>