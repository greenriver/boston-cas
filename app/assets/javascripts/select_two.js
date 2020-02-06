//= require namespace
//= require select2

App.Form = App.Form || {}

App.Form.Select2Input = class Select2Input {
  constructor(elementId) {
    const field = document.getElementById(elementId);
    if (!field) {
      console.debug(`Select2Input could not find id: ${elementId}`)
    } else {
      this.id = elementId
      $(field).select2();
    }
  }
}
