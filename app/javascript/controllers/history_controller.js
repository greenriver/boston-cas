/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

// NOTE: When poll is enabled, this controller polls the history URL and replaces the
// section when event count changes. When the DOM is replaced, Stimulus disconnects
// the old controller and connects to the new element. connect() must re-init ALL JS:
// Select2, datepickers, tooltips. disconnect() cleans up.

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['row', 'collapseSelect', 'dateRangeRow', 'dateStart', 'dateEnd', 'eventSelect', 'contactSelect']

  connect() {
    this.restorePollState()
    this.buildFilterOptions()
    this.toggleDateRangeVisibility()
    this.initSelects()
    this.initDateChangeListeners()
    this.apply()
    this.element.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((el) => {
      if (typeof jQuery !== 'undefined') jQuery(el).tooltip()
    })
    if (this.shouldPoll()) this.startPolling()
  }

  initDateChangeListeners() {
    // The datepicker Stimulus controller initializes TempusDominus and dispatches
    // a standard `change` event on the input when a date is selected.
    if (this.hasDateStartTarget) {
      this._dateStartHandler = () => this.apply()
      this.dateStartTarget.addEventListener('change', this._dateStartHandler)
    }
    if (this.hasDateEndTarget) {
      this._dateEndHandler = () => this.apply()
      this.dateEndTarget.addEventListener('change', this._dateEndHandler)
    }
  }

  initSelects() {
    if (typeof jQuery === 'undefined') return
    if (this.hasCollapseSelectTarget) this.initSingleSelect(this.collapseSelectTarget, true)
    if (this.hasEventSelectTarget) this.initSingleSelect(this.eventSelectTarget, true)
    if (this.hasContactSelectTarget) {
      const $el = jQuery(this.contactSelectTarget)
      if ($el.hasClass('select2-hidden-accessible')) $el.select2('destroy')
      $el.select2({
        placeholder: 'All contacts',
        allowClear: true,
      })
      $el.off('change.historyFilter').on('change.historyFilter', () => this.apply())
    }
  }

  initSingleSelect(el, isHistoryFilter, opts = {}) {
    if (!el) return
    const $el = jQuery(el)
    if ($el.hasClass('select2-hidden-accessible')) $el.select2('destroy')
    $el.select2(opts)
    if (isHistoryFilter) {
      $el.off('change.historyFilter').on('change.historyFilter', () => {
        this.toggleDateRangeVisibility()
        this.apply()
      })
    }
  }

  disconnect() {
    if (this._pollIntervalId) {
      clearInterval(this._pollIntervalId)
      this._pollIntervalId = null
    }
    if (typeof jQuery !== 'undefined') {
      const selects = []
      if (this.hasCollapseSelectTarget) selects.push(this.collapseSelectTarget)
      if (this.hasEventSelectTarget) selects.push(this.eventSelectTarget)
      if (this.hasContactSelectTarget) selects.push(this.contactSelectTarget)
      selects.forEach((el) => {
        const $el = jQuery(el)
        $el.off('change.historyFilter')
        if ($el.hasClass('select2-hidden-accessible')) $el.select2('destroy')
      })
    }
    if (this.hasDateStartTarget && this._dateStartHandler) {
      this.dateStartTarget.removeEventListener('change', this._dateStartHandler)
      this._dateStartHandler = null
    }
    if (this.hasDateEndTarget && this._dateEndHandler) {
      this.dateEndTarget.removeEventListener('change', this._dateEndHandler)
      this._dateEndHandler = null
    }
  }

  shouldPoll() {
    const wrapper = this.element.closest('.jDynamicHistory')
    return wrapper?.getAttribute('data-history-poll') === 'true'
  }

  startPolling() {
    const wrapper = this.element.closest('.jDynamicHistory')
    const path = wrapper?.getAttribute('data-history-path')
    if (!path) return
    let refreshCount = 0
    this._pollIntervalId = setInterval(() => {
      fetch(path)
        .then((r) => r.text())
        .then((html) => {
          const parser = new DOMParser()
          const doc = parser.parseFromString(html, 'text/html')
          const newCard = doc.querySelector('.jHistoryCount')
          const oldEventCount = this.element.dataset.historyEvents
          const newEventCount = newCard?.dataset?.historyEvents
          if (newEventCount !== oldEventCount) {
            const state = this.captureState()
            const wrapper = this.element.closest('.jDynamicHistory')
            if (wrapper && typeof jQuery !== 'undefined') {
              jQuery(wrapper).data('history-restore', state)
            }
            if (wrapper) wrapper.innerHTML = html
          }
          refreshCount++
          if (refreshCount >= 10 && this._pollIntervalId) {
            clearInterval(this._pollIntervalId)
            this._pollIntervalId = null
          }
        })
        .catch(() => {})
    }, 10000)
  }

  captureState() {
    return {
      collapse: this.hasCollapseSelectTarget ? this.collapseSelectTarget.value : null,
      dateStart: this.hasDateStartTarget ? this.dateStartTarget.value : null,
      dateEnd: this.hasDateEndTarget ? this.dateEndTarget.value : null,
      eventType: this.hasEventSelectTarget ? this.eventSelectTarget.value : null,
      contactIds: this.getSelectedContactIds()
    }
  }

  restorePollState() {
    const $wrap = typeof jQuery !== 'undefined' ? jQuery(this.element).closest('.jDynamicHistory') : null
    if (!$wrap?.length) return
    const state = $wrap.data('history-restore')
    if (!state) return
    $wrap.removeData('history-restore')
    if (this.hasCollapseSelectTarget && state.collapse != null) this.collapseSelectTarget.value = state.collapse
    if (this.hasDateStartTarget && state.dateStart != null) this.dateStartTarget.value = state.dateStart
    if (this.hasDateEndTarget && state.dateEnd != null) this.dateEndTarget.value = state.dateEnd
    this._restoreState = { eventType: state.eventType, contactIds: state.contactIds || [] }
  }

  apply() {
    this.applyCollapse()
    this.applyFilters()
  }

  applyCollapse() {
    if (this.isCustomRange) {
      this.rowTargets.forEach((row) => {
        row.dataset.collapseHidden = ''
      })
      return
    }
    const limit = this.collapseLimitValue
    this.rowTargets.forEach((row) => {
      const daysAgo = parseInt(row.dataset.historyDaysAgo, 10)
      const hideByCollapse = !isNaN(daysAgo) && limit !== null && daysAgo > limit
      row.dataset.collapseHidden = hideByCollapse || ''
    })
  }

  toggleDateRangeVisibility() {
    if (!this.hasDateRangeRowTarget) return
    this.dateRangeRowTarget.hidden = !this.isCustomRange
  }

  get isCustomRange() {
    return this.collapseSelectTarget?.value === 'custom'
  }

  applyFilters() {
    const isCustomRange = this.isCustomRange
    const startDate = isCustomRange && this.hasDateStartTarget && this.dateStartTarget?.value
      ? this.parseDate(this.dateStartTarget.value)
      : null
    const endDate = isCustomRange && this.hasDateEndTarget && this.dateEndTarget?.value
      ? this.parseDate(this.dateEndTarget.value)
      : null
    const eventType = this.eventSelectTarget?.value || null
    const contactIds = this.getSelectedContactIds()

    const dateRangeValid = !startDate || !endDate || startDate <= endDate

    this.rowTargets.forEach((row) => {
      let visible = !row.dataset.collapseHidden
      if (!visible) {
        row.hidden = true
        return
      }

      if (isCustomRange && !dateRangeValid) {
        visible = false
      } else if (isCustomRange && (startDate || endDate)) {
        const rowDate = this.parseDate(row.dataset.historyDate)
        if (rowDate) {
          if (startDate && rowDate < startDate) visible = false
          if (endDate && rowDate > endDate) visible = false
        } else {
          visible = false
        }
      }

      if (visible && eventType) {
        const rowEvent = row.dataset.historyEventType
        visible = rowEvent === eventType
      }

      if (visible && contactIds.length > 0) {
        const rowIds = (row.dataset.historyContactIds || '').split(',').filter(Boolean)
        const hasMatch = contactIds.some((id) => rowIds.includes(String(id)))
        visible = hasMatch
      }

      row.hidden = !visible
    })
  }

  buildFilterOptions() {
    if (!this.hasEventSelectTarget || !this.hasContactSelectTarget) return

    const eventTypes = new Set()
    const contactOptions = new Map()

    this.rowTargets.forEach((row) => {
      const et = row.dataset.historyEventType
      if (et) eventTypes.add(et)

      const ids = (row.dataset.historyContactIds || '').split(',')
      const names = (row.dataset.historyContactNames || '').split('|')
      ids.forEach((id, i) => {
        id = id.trim()
        if (id && !contactOptions.has(id)) {
          contactOptions.set(id, names[i] ? names[i].trim() : id)
        }
      })
    })

    const eventSelect = this.eventSelectTarget
    const currentValue = (this._restoreState?.eventType != null) ? this._restoreState.eventType : eventSelect.value
    eventSelect.innerHTML = '<option value="">All events</option>'
    Array.from(eventTypes)
      .sort()
      .forEach((et) => {
        const opt = document.createElement('option')
        opt.value = et
        opt.textContent = et
        if (et === currentValue) opt.selected = true
        eventSelect.appendChild(opt)
      })

    const contactSelect = this.contactSelectTarget
    const selectedValues = (this._restoreState?.contactIds?.length > 0)
      ? this._restoreState.contactIds
      : (typeof jQuery !== 'undefined'
        ? (jQuery(contactSelect).val() || [])
        : Array.from(contactSelect.selectedOptions).map((o) => o.value))
    contactSelect.innerHTML = ''
    Array.from(contactOptions.entries())
      .sort((a, b) => (a[1] || '').localeCompare(b[1] || ''))
      .forEach(([id, name]) => {
        const opt = document.createElement('option')
        opt.value = id
        opt.textContent = name || id
        if (Array.isArray(selectedValues) ? selectedValues.includes(id) : selectedValues === id) opt.selected = true
        contactSelect.appendChild(opt)
      })
    this._restoreState = null
  }

  getSelectedContactIds() {
    if (!this.hasContactSelectTarget) return []
    if (typeof jQuery !== 'undefined') {
      const val = jQuery(this.contactSelectTarget).val()
      return Array.isArray(val) ? val : (val ? [val] : [])
    }
    return Array.from(this.contactSelectTarget.selectedOptions).map((o) => o.value)
  }

  parseDate(str) {
    if (!str) return null
    const d = new Date(str)
    return isNaN(d.getTime()) ? null : d
  }

  get collapseLimitValue() {
    if (!this.hasCollapseSelectTarget) return 90
    const val = this.collapseSelectTarget.value
    if (val === 'all' || val === '') return null
    const n = parseInt(val, 10)
    return isNaN(n) ? 90 : n
  }
}
