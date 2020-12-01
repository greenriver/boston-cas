<% if @match_note.errors.any? %>
  $('.note-form').html "<%=j render 'form' %>"
  $('.select2').select2()
<% else %>
  console.log('test')
  window.ajaxModalInstance.closeModal()
  $('#ajax-modal').modal('hide')
  window.location.reload()
<% end %>
