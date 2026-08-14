/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['list']

  connect() {
    this.nextIndex = this.listTarget.querySelectorAll('[data-attr-entry]').length
    this.attachNameHandlers(this.listTarget)
  }

  addAttribute() {
    const template = this.element.querySelector('template[data-attr-template]')
    const unitIndex = this.element.dataset.unitIndex
    const attrIndex = this.nextIndex
    const html = template.innerHTML
      .replaceAll('__UNIT_INDEX__', unitIndex)
      .replaceAll('__ATTR_INDEX__', attrIndex)
    this.listTarget.insertAdjacentHTML('beforeend', html)
    const entries = this.listTarget.querySelectorAll('[data-attr-entry]')
    this.initSelect2(entries[entries.length - 1])
    this.nextIndex++
  }

  removeAttribute(event) {
    event.currentTarget.closest('[data-attr-entry]').remove()
  }

  cascadeValues(nameSelect) {
    const entry = nameSelect.closest('[data-attr-entry]')
    const valueSelect = entry.querySelector('[data-attr-value-select]')
    if (!valueSelect) return

    const catalog = JSON.parse(this.element.dataset.attributeCatalog || '{}')
    const values = catalog[nameSelect.value] || []

    if (window.$) $(valueSelect).select2('destroy')

    const fragment = document.createDocumentFragment()
    const blank = document.createElement('option')
    blank.value = ''
    blank.textContent = 'Select value...'
    fragment.appendChild(blank)
    values.forEach((v) => {
      const opt = document.createElement('option')
      opt.value = v
      opt.textContent = v
      fragment.appendChild(opt)
    })
    valueSelect.replaceChildren(fragment)

    if (window.App?.Form?.Select2Input) new window.App.Form.Select2Input(valueSelect)
  }

  attachNameHandlers(container) {
    if (!window.$) return
    $(container).find('[data-attr-name-select]')
      .off('change.vacancyUnitAttr')
      .on('change.vacancyUnitAttr', (e) => this.cascadeValues(e.currentTarget))
  }

  initSelect2(container) {
    if (!window.App?.Form?.Select2Input) return
    container.querySelectorAll('select.select2').forEach((el) => {
      new window.App.Form.Select2Input(el)
    })
    this.attachNameHandlers(container)
  }
}
