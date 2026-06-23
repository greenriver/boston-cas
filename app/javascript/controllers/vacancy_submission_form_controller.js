/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'programSelect',
    'subProgramSelect',
    'routeContainer',
    'requirementsContainer',
    'documentsContainer',
    'vacancyContainer',
  ]

  static values = {
    programs: Array,
    initialProgram: Number,
    initialSubProgram: Number,
    vacancySubmissionId: Number,
  }

  connect() {
    this.isInitializing = true
    this.programMap = {}
    this.programsValue.forEach((p) => {
      this.programMap[p.id] = p
    })

    if (typeof $ !== 'undefined') {
      $(this.programSelectTarget).on('change.vacancy-form', () => {
        this.onProgramChange()
      })
      $(this.subProgramSelectTarget).on('change.vacancy-form', () => {
        this.onSubProgramChange()
      })
    } else {
      this.programSelectTarget.addEventListener('change', () => this.onProgramChange())
      this.subProgramSelectTarget.addEventListener('change', () => this.onSubProgramChange())
    }

    if (this.initialProgramValue) {
      this.populateSubPrograms(this.initialProgramValue, this.initialSubProgramValue)
    }
    this.isInitializing = false
    if (this.initialSubProgramValue) {
      this.refreshAll()
    }
  }

  disconnect() {
    if (typeof $ !== 'undefined') {
      $(this.programSelectTarget).off('change.vacancy-form')
      $(this.subProgramSelectTarget).off('change.vacancy-form')
    }
  }

  onProgramChange() {
    const value = parseInt(this.programSelectTarget.value, 10)
    this.populateSubPrograms(value, null)
  }

  onSubProgramChange() {
    this.refreshAll()
  }

  populateSubPrograms(programId, selectedSubProgramId) {
    const sub = this.subProgramSelectTarget
    sub.innerHTML = ''

    const program = this.programMap[programId]
    if (!programId || !program) {
      sub.disabled = true
      this.refreshAll()
      return
    }

    program.sub_programs.forEach((sp) => {
      const selected = selectedSubProgramId && String(sp.id) === String(selectedSubProgramId)
      const option = new Option(sp.name, sp.id, false, selected)
      option.dataset.isVoucher = sp.is_voucher
      option.dataset.programType = sp.program_type || ''
      sub.append(option)
    })

    sub.disabled = false
    if (typeof $ !== 'undefined') {
      $(sub).trigger('change')
    }
    this.refreshAll()
  }

  static sectionDefs = [
    { target: 'routeContainer', section: 'route', emptyHtml: '' },
    { target: 'requirementsContainer', section: 'requirements', emptyHtml: '<p class="text-muted">Select a sub-program to see inherited requirements.</p>' },
    { target: 'documentsContainer', section: 'required_documents', emptyHtml: '' },
    { target: 'vacancyContainer', section: 'vacancy', emptyHtml: '<p class="text-muted">Select a sub-program to see unit type information.</p>' },
  ]

  refreshAll() {
    this.constructor.sectionDefs.forEach(def => this.refreshSection(def))
  }

  async refreshSection({ target, section, emptyHtml }) {
    if (this.isInitializing) return

    const hasProp = `has${target[0].toUpperCase()}${target.slice(1)}Target`
    if (!this[hasProp]) return

    const containerProp = `${target}Target`
    const subProgramId = this.subProgramSelectTarget.value
    if (!subProgramId) {
      this[containerProp].innerHTML = emptyHtml
      return
    }

    let url = `/vacancy_submissions/sub_program_section?sub_program_id=${subProgramId}&section=${section}`
    if (this.vacancySubmissionIdValue) url += `&vacancy_submission_id=${this.vacancySubmissionIdValue}`

    if (section === 'required_documents') {
      const raw = this[containerProp].dataset.selectedNames
      if (raw) {
        const names = JSON.parse(raw)
        names.forEach(name => { url += `&required_document_names[]=${encodeURIComponent(name)}` })
        delete this[containerProp].dataset.selectedNames
      }
    }

    const response = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
    this[containerProp].innerHTML = await response.text()
    this.applyErrors(this[containerProp])
  }

  applyErrors(container) {
    const raw = container.dataset.fieldErrors
    if (!raw) return
    let errors
    try { errors = JSON.parse(raw) } catch { return }
    delete container.dataset.fieldErrors
    if (!errors.length) return

    container.querySelectorAll('input[required]').forEach((input) => {
      if (input.value.trim() === '') {
        input.classList.add('is-invalid')
        const feedback = document.createElement('div')
        feedback.className = 'invalid-feedback'
        feedback.textContent = 'This field is required.'
        input.after(feedback)
      }
    })
  }
}
