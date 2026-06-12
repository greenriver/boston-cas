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
    'resourceTypeDisplay',
    'unitTypeDisplay',
    'unitTypeHint',
    'addressFields',
  ]

  static values = {
    programs: Array,
    initialProgram: Number,
    initialSubProgram: Number,
  }

  connect() {
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
    this.refreshUnitType()
  }

  populateSubPrograms(programId, selectedSubProgramId) {
    const sub = this.subProgramSelectTarget
    sub.innerHTML = ''

    const program = this.programMap[programId]
    if (!programId || !program) {
      sub.disabled = true
      this.resourceTypeDisplayTarget.textContent = '—'
      this.refreshUnitType()
      return
    }

    this.resourceTypeDisplayTarget.textContent = program.resource_type || '—'

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
    this.refreshUnitType()
  }

  refreshUnitType() {
    const sub = this.subProgramSelectTarget
    const selected = sub.options[sub.selectedIndex]

    if (!selected || !selected.value) {
      this.unitTypeDisplayTarget.textContent = '—'
      this.unitTypeHintTarget.textContent = ''
      this.addressFieldsTarget.hidden = true
      return
    }

    const isVoucher = selected.dataset.isVoucher === 'true'
    const programType = selected.dataset.programType || ''

    if (isVoucher) {
      this.unitTypeDisplayTarget.textContent = 'Voucher'
      this.unitTypeHintTarget.textContent = 'Tenant-Based — no physical address required'
      this.addressFieldsTarget.hidden = true
    } else {
      this.unitTypeDisplayTarget.textContent = 'Physical Unit'
      this.unitTypeHintTarget.textContent = programType ? 'Sub-program type: ' + programType : ''
      this.addressFieldsTarget.hidden = false
    }
  }
}
