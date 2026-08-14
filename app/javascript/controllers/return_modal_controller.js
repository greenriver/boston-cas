/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['textarea', 'submitButton']

  connect() {
    this.toggle()
  }

  onInput() {
    this.toggle()
  }

  toggle() {
    this.submitButtonTarget.disabled = this.textareaTarget.value.trim() === ''
  }
}
