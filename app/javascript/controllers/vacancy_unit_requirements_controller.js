/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'
import { RequirementVariableMixin } from './requirement_variable_mixin'

class VacancyUnitRequirementsController extends Controller {
  static targets = ['list']

  connect() {
    this.nextIndex = this.listTarget.querySelectorAll('[data-req-entry]').length
    // Select2 on existing rows is initialized by the parent vacancy-units controller.
    // We only wire change handlers and multi-select sync here.
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
    event.currentTarget.closest('[data-req-entry]').remove()
  }

  initEntry(entry, isNew) {
    // Only initialize Select2 for dynamically added rows; parent handles existing ones.
    if (isNew && window.App?.Form?.Select2Input) {
      entry.querySelectorAll('select.select2').forEach((el) => {
        new window.App.Form.Select2Input(el, this.select2Options(el))
      })
    }
    this.wireMultiSelectSync(entry)
    const ruleSelect = entry.querySelector('[data-req-rule-select]')
    if (!ruleSelect) return
    const update = () => this.updateVariableInput(entry, ruleSelect)
    if (window.$) {
      $(ruleSelect).off('change.vacancyReqs').on('change.vacancyReqs', update)
    } else {
      ruleSelect.addEventListener('change', update)
    }
    if (isNew) update()
  }
}

Object.assign(VacancyUnitRequirementsController.prototype, RequirementVariableMixin)
export default VacancyUnitRequirementsController
