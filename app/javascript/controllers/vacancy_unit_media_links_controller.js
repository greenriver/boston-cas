/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['list']

  connect() {
    this.nextIndex = this.listTarget.querySelectorAll('[data-media-link-entry]').length
  }

  addLink() {
    const template = this.element.querySelector('template[data-media-link-template]')
    const unitIndex = this.element.dataset.unitIndex
    const linkIndex = this.nextIndex
    const html = template.innerHTML
      .replaceAll('__UNIT_INDEX__', unitIndex)
      .replaceAll('__LINK_INDEX__', linkIndex)
    this.listTarget.insertAdjacentHTML('beforeend', html)
    this.nextIndex++
  }

  removeLink(event) {
    event.currentTarget.closest('[data-media-link-entry]').remove()
  }
}
