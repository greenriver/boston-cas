/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['list']
  static values = { isVoucher: Boolean }

  connect() {
    this.nextIndex = this.listTarget.querySelectorAll('[data-unit-entry]').length
    this.updateRemoveButtons()
  }

  addUnit() {
    const template = this.element.querySelector('template[data-unit-template]')
    const number = this.nextIndex + 1
    const html = template.innerHTML
      .replaceAll('__INDEX__', this.nextIndex)
      .replaceAll('__NUMBER__', number)
    this.listTarget.insertAdjacentHTML('beforeend', html)
    this.nextIndex++
    this.renumber()
    this.updateRemoveButtons()
  }

  removeUnit(event) {
    event.currentTarget.closest('[data-unit-entry]').remove()
    this.renumber()
    this.updateRemoveButtons()
  }

  renumber() {
    const entries = this.listTarget.querySelectorAll('[data-unit-entry]')
    if (this.isVoucherValue) {
      entries.forEach((entry, index) => {
        const label = entry.querySelector('[data-voucher-label]')
        const input = entry.querySelector('[data-voucher-name]')
        const number = index + 1
        if (label) label.textContent = `Voucher ${number}`
        if (input) input.value = `Voucher ${number}`
      })
    } else {
      entries.forEach((entry, index) => {
        const title = entry.querySelector('[data-unit-card-title]')
        if (title) title.textContent = `Unit ${index + 1}`
      })
    }
  }

  updateRemoveButtons() {
    const entries = this.listTarget.querySelectorAll('[data-unit-entry]')
    entries.forEach((entry, index) => {
      const btn = entry.querySelector('[data-action="vacancy-units#removeUnit"]')
      if (btn) btn.hidden = index === 0
    })
  }
}
