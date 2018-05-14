//= require namespace

// Use checkboxes like radio buttons that can also be completely un-selected
// Example Usage: new window.App.SingleOptionCheckboxes( $('form.edit_decision')[0], 'decision[match_decision_reason][]')
window.App.SingleOptionCheckboxes = class SingleOptionCheckboxes {
  constructor(form_element, form_input_name) {
    this.form_element = form_element
    this.form_input_name = form_input_name

    $(form_element).on('change', `[name="${form_input_name}"]`, evt => {
      $(form_element).find(`[name="${form_input_name}"]`).each( (_i, input_element) => {
        if(input_element != evt.target) {
          $(input_element).prop('checked', false)
        }
      })
    })


  }
}
