/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

import { Controller } from '@hotwired/stimulus'
import { TempusDominus, DateTime } from '@eonasdan/tempus-dominus'

// Connects to data-controller="datepicker"
export default class extends Controller {
  connect() {
    const dropdownMenu = this.element.closest('.dropdown-menu')
    const containerOptions = dropdownMenu ? { container: dropdownMenu } : {}

    const defaultOptions = {
      ...containerOptions,
      display: {
        icons: {
          time: 'fa fa-clock-o',
          date: 'fa fa-calendar',
          up: 'fa fa-arrow-up',
          down: 'fa fa-arrow-down',
          previous: 'fa fa-chevron-left',
          next: 'fa fa-chevron-right',
          today: 'fa fa-calendar',
          clear: 'fa fa-trash',
          close: 'fa fa-times',
        },
        theme: 'light',
        buttons: {
          today: true,
          clear: true,
          close: true,
        },
        components: {
          calendar: true,
          date: true,
          month: true,
          year: true,
          decades: true,
          clock: false,
          hours: false,
          minutes: false,
          seconds: false,
        },
      },
      localization: {
        format: 'MMM d, yyyy',
        dayViewHeaderFormat: { month: 'long', year: 'numeric' },
      },
    }

    const elementOptions = this.element.dataset.dateOptions
      ? JSON.parse(this.element.dataset.dateOptions)
      : {}

    const finalOptions = this.deepMerge(defaultOptions, elementOptions)

    this.datepicker = new TempusDominus(this.element, finalOptions)

    const originalParseInput = this.datepicker.dates.parseInput.bind(this.datepicker.dates)
    this.datepicker.dates.parseInput = (value) => this.parseFlexibleDateInput(value, originalParseInput)

    // Dispatch a standard change event on the input so submit-on-change and
    // other listeners (e.g. the history controller) receive a native input change.
    this.element.addEventListener('change.td', (_event) => {
      const inputField = this.element.querySelector('input')
      if (inputField) {
        inputField.dispatchEvent(new CustomEvent('change', { bubbles: true, cancelable: true, detail: true }))
      }
    })
  }

  disconnect() {
    if (this.datepicker && typeof this.datepicker.dispose === 'function') {
      this.datepicker.dispose()
      this.datepicker = null
    }
  }

  parseFlexibleDateInput(value, originalParseInput) {
    if (!value || value.toString().trim() === '') {
      return originalParseInput(value)
    }

    const rawValue = value.toString().trim()

    let optionsData = {}
    try {
      optionsData = this.element.dataset.dateOptions ? JSON.parse(this.element.dataset.dateOptions) : {}
    } catch (_) {
      optionsData = {}
    }

    const locale = optionsData.localization?.locale || 'en-US'
    const normalizedValue = this.normalizeMonthAliases(rawValue, locale)
    const localizationForFormat = (format) => {
      if (optionsData.localization) {
        return { ...optionsData.localization, locale, format }
      }
      return { locale, format }
    }

    const tryOriginalParse = (candidate) => {
      try {
        const result = originalParseInput(candidate)
        if (result && result.isValid) return result
      } catch (_) { }
      return undefined
    }

    let parsed = tryOriginalParse(rawValue)
    if (parsed) return parsed

    if (normalizedValue !== rawValue) {
      parsed = tryOriginalParse(normalizedValue)
      if (parsed) return parsed
    }

    const configuredFormat = optionsData.localization?.format || ''
    const isDateTimeFormat = /[hHtT]/.test(configuredFormat)

    const dateTimeFormats = isDateTimeFormat ? [
      'MMM d, yyyy h:mm T',
      'MMM d, yyyy h:mm t',
      'MMMM d, yyyy h:mm T',
      'MMMM d, yyyy h:mm t',
      'MMM d, yyyy HH:mm',
    ] : []

    const formats = [
      ...dateTimeFormats,
      'MMM d, yyyy',
      'MMMM d, yyyy',
      'MM/dd/yyyy',
      'M/d/yyyy',
      'MM-dd-yyyy',
      'M-d-yyyy',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'MM/dd/yy',
      'M/d/yy',
      'MM-dd-yy',
      'M-d-yy',
    ]

    const parseCandidates = normalizedValue === rawValue ? [normalizedValue] : [normalizedValue, rawValue]
    for (const candidate of parseCandidates) {
      for (const fmt of formats) {
        try {
          const dt = DateTime.fromString(candidate, localizationForFormat(fmt))
          if (dt && DateTime.isValid(dt)) return dt
        } catch (_) { }
      }
    }

    for (const candidate of parseCandidates) {
      const nativeDate = new Date(candidate)
      if (!Number.isNaN(nativeDate.getTime())) {
        try {
          const localization = optionsData.localization ? { ...optionsData.localization, locale } : { locale }
          return DateTime.convert(nativeDate, locale, localization)
        } catch (_) { }
      }
    }

    return originalParseInput(value)
  }

  normalizeMonthAliases(value, locale) {
    const normalizedLocale = (locale || '').toLowerCase()
    if (!normalizedLocale.startsWith('en')) return value
    return value.replace(/\bsept\.?\b/gi, (match) => this.applyMatchCase(match.replace(/\./g, ''), 'Sep'))
  }

  applyMatchCase(source, target) {
    if (source === source.toUpperCase()) return target.toUpperCase()
    if (source === source.toLowerCase()) return target.toLowerCase()
    return target[0].toUpperCase() + target.slice(1)
  }

  deepMerge(target, source) {
    const result = { ...target }
    for (const key of Object.keys(source)) {
      if (
        source[key] !== null &&
        typeof source[key] === 'object' &&
        !Array.isArray(source[key]) &&
        target[key] !== null &&
        typeof target[key] === 'object' &&
        !Array.isArray(target[key])
      ) {
        result[key] = this.deepMerge(target[key], source[key])
      } else {
        result[key] = source[key]
      }
    }
    return result
  }
}
