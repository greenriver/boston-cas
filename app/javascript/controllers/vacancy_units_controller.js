/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['list']

  connect() {
    this.nextIndex = this.listTarget.querySelectorAll('[data-unit-entry]').length
    this.updateRemoveButtons()
  }

  addUnit() {
    const template = this.element.querySelector('template[data-unit-template]')
    const html = template.innerHTML.replaceAll('__INDEX__', this.nextIndex)
    this.listTarget.insertAdjacentHTML('beforeend', html)
    this.nextIndex++
    this.updateRemoveButtons()
  }

  removeUnit(event) {
    event.currentTarget.closest('[data-unit-entry]').remove()
    this.updateRemoveButtons()
  }

  updateRemoveButtons() {
    const entries = this.listTarget.querySelectorAll('[data-unit-entry]')
    entries.forEach((entry) => {
      const btn = entry.querySelector('[data-action="vacancy-units#removeUnit"]')
      if (btn) btn.disabled = entries.length <= 1
    })
  }
}
