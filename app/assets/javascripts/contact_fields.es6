// Contact pickers rendered by contact_manager/_contact_field save on every pick or removal,
// and a successful response replaces the whole form. Fields stay disabled while a save is
// in flight: a dropdown opened mid-save is orphaned by the replacement, and overlapping
// saves each re-create the full contact list, duplicating rows.
const contactFormSelector = '.jContactForm, .jDnDStaffContactForm'

$(document).on('change', '.jContactField', function () {
  const $input = $(this)
  const val = $input.val()
  if (!val) return

  $('<input type="hidden" class="jContactPending">')
    .attr({ name: $input.data('input-name'), value: val })
    .insertAfter($input)
  $input.closest('form').trigger('submit')
})

$(document).on('click', '.jContactDelete', function (e) {
  e.preventDefault()
  const $form = $(this).closest('form')
  if ($form.hasClass('jContactSaving')) return

  $form.find(`.jContactHidden[value="${$(this).data('contact-id')}"][name="${$(this).data('input-name')}"]`).remove()
  $form.trigger('submit')
})

$(document).on('ajax:send', contactFormSelector, function () {
  $(this).addClass('jContactSaving').find('.jContactField').prop('disabled', true)
})

// Fires only when the form survived the response (validation or server error); on success
// the form has already been replaced.
$(document).on('ajax:complete', contactFormSelector, function () {
  const $form = $(this)
  $form.removeClass('jContactSaving').find('.jContactField').prop('disabled', false).val('').trigger('change.select2')
  $form.find('.jContactPending').remove()
})

$(document).on('ajax:error', contactFormSelector, function () {
  const $form = $(this)
  $form.find('.jContactFormErrors').remove()
  $form.prepend('<div class="alert alert-danger jContactFormErrors">Contacts could not be saved. Reload the page to see the current contacts.</div>')
})
