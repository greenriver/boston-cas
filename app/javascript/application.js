/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import * as bootstrap from 'bootstrap'
import { Application } from '@hotwired/stimulus'
import DatepickerController from './controllers/datepicker_controller'
import HistoryController from './controllers/history_controller'
import ReturnModalController from './controllers/return_modal_controller'
import RoleManagerController from './controllers/role_manager_controller'
import VacancySubmissionFormController from './controllers/vacancy_submission_form_controller'
import RequirementsController from './controllers/requirements_controller'

// Expose bootstrap globally for any legacy inline scripts that reference window.bootstrap
window.bootstrap = bootstrap

// Initialize Bootstrap tooltips and popovers after DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((el) => {
    bootstrap.Tooltip.getOrCreateInstance(el)
  })
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((el) => {
    new bootstrap.Popover(el)
  })

  const matchesCollapseKey = 'cas-sidebar-matches-collapsed'
  const matchesCollapseEl = document.getElementById('matches-submenu')
  if (matchesCollapseEl) {
    matchesCollapseEl.addEventListener('hidden.bs.collapse', () => {
      sessionStorage.setItem(matchesCollapseKey, '1')
    })
    matchesCollapseEl.addEventListener('shown.bs.collapse', () => {
      sessionStorage.removeItem(matchesCollapseKey)
    })

    if (sessionStorage.getItem(matchesCollapseKey) === '1') {
      const collapse = bootstrap.Collapse.getOrCreateInstance(matchesCollapseEl, { toggle: false })
      collapse.hide()
    }
  }
})

// Start Stimulus
const application = Application.start()
application.register('datepicker', DatepickerController)
application.register('history', HistoryController)
application.register('return-modal', ReturnModalController)
application.register('role-manager', RoleManagerController)
application.register('vacancy-submission-form', VacancySubmissionFormController)
application.register('requirements', RequirementsController)
