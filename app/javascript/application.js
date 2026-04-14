/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import * as bootstrap from 'bootstrap'
import { Application } from '@hotwired/stimulus'
import HistoryController from './controllers/history_controller'
import DatepickerController from './controllers/datepicker_controller'

// Expose bootstrap globally for any legacy inline scripts that reference window.bootstrap
window.bootstrap = bootstrap

// Initialize Bootstrap tooltips and popovers after DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((el) => {
    new bootstrap.Tooltip(el)
  })
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((el) => {
    new bootstrap.Popover(el)
  })
})

// Start Stimulus
const application = Application.start()
application.register('history', HistoryController)
application.register('datepicker', DatepickerController)
