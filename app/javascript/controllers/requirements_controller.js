/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'
import { RequirementVariableMixin } from './requirement_variable_mixin'

class RequirementsController extends Controller {
  static targets = ['list']

  connect() {
    this.nextIndex = this.listTarget.querySelectorAll('[data-req-entry]').length
    this.listTarget.querySelectorAll('[data-req-entry]').forEach((entry) => {
      this.initEntry(entry, false)
    })
  }

  addReq() {
    const template = this.element.querySelector('template[data-req-template]')
    const html = template.innerHTML.replaceAll('__REQ__', this.nextIndex)
    this.listTarget.insertAdjacentHTML('beforeend', html)
    const entries = this.listTarget.querySelectorAll('[data-req-entry]')
    const newEntry = entries[entries.length - 1]
    this.initEntry(newEntry, true)
    this.nextIndex++
  }

  removeReq(event) {
    const entry = event.currentTarget.closest('[data-req-entry]')
    const destroyInput = entry.querySelector('[data-req-destroy]')
    if (destroyInput) {
      destroyInput.value = '1'
      entry.hidden = true
    } else {
      entry.remove()
    }
  }

  initEntry(entry, isNew) {
    if (window.App?.Form?.Select2Input) {
      entry.querySelectorAll('select.select2').forEach((el) => {
        new window.App.Form.Select2Input(el, this.select2Options(el))
      })
    }
    this.wireMultiSelectSync(entry)
    const ruleSelect = entry.querySelector('[data-req-rule-select]')
    if (!ruleSelect) return
    const update = () => this.updateVariableInput(entry, ruleSelect)
    if (window.$) {
      $(ruleSelect).off('change.requirements').on('change.requirements', update)
    } else {
      ruleSelect.addEventListener('change', update)
    }
    if (isNew) update()
  }
}

Object.assign(RequirementsController.prototype, RequirementVariableMixin)
export default RequirementsController
