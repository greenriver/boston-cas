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

    if (this.initialProgramValue) {
      this.populateSubPrograms(this.initialProgramValue, this.initialSubProgramValue)
    }
  }

  onProgramChange() {
    this.populateSubPrograms(parseInt(this.programSelectTarget.value, 10), null)
  }

  onSubProgramChange() {
    this.refreshUnitType()
  }

  populateSubPrograms(programId, selectedSubProgramId) {
    const $sub = $(this.subProgramSelectTarget)
    $sub.empty().append('<option value="">-- Select a sub-program --</option>')

    const program = this.programMap[programId]
    if (!programId || !program) {
      $sub.prop('disabled', true).trigger('change')
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
      $sub.append(option)
    })

    $sub.prop('disabled', false).trigger('change')
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
