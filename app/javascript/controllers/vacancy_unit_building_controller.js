/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'

// Shows the selected building's name and full address below the building
// dropdown. select2 fires a native `change` on the underlying select, so the
// change action wires straight through.
export default class extends Controller {
  static targets = ['select', 'display']

  connect() {
    this.render()
  }

  render() {
    const option = this.selectTarget.selectedOptions[0]
    if (!option || !option.value) {
      this.displayTarget.hidden = true
      this.displayTarget.replaceChildren()
      return
    }

    const name = option.dataset.name || option.textContent
    const address = option.dataset.address || ''

    this.displayTarget.replaceChildren()
    const nameEl = document.createElement('div')
    nameEl.className = 'fw-semibold'
    nameEl.textContent = name
    this.displayTarget.appendChild(nameEl)

    if (address) {
      const addressEl = document.createElement('div')
      addressEl.className = 'text-muted'
      addressEl.textContent = address
      this.displayTarget.appendChild(addressEl)
    }

    this.displayTarget.hidden = false
  }
}
