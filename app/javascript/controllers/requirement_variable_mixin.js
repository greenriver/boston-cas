/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

// Shared variable-input logic for both requirements controllers.
// Mixed into controller prototypes after class definition.
export const RequirementVariableMixin = {
  select2Options(el) {
    if (!window.$) return {}
    const modalContent = el.closest('.modal-content')
    return modalContent ? { dropdownParent: $(modalContent) } : {}
  },

  wireMultiSelectSync(entry) {
    const multiDisplay = entry.querySelector('[data-req-multi-display]')
    if (!multiDisplay) return
    const hidden = entry.querySelector('[data-req-variable]')
    if (!hidden) return
    const sync = () => {
      hidden.value = Array.from(multiDisplay.selectedOptions)
        .map((o) => o.value)
        .join(',')
    }
    multiDisplay.addEventListener('change', sync)
    if (window.$) $(multiDisplay).on('select2:select select2:unselect', sync)
  },

  updateVariableInput(entry, ruleSelect) {
    const container = entry.querySelector('[data-req-variable-container]')
    if (!container) return
    const selected = ruleSelect.options[ruleSelect.selectedIndex]
    const isVariable = selected?.dataset.variable === 'true'
    if (!isVariable) {
      container.hidden = true
      container.innerHTML = ''
      return
    }
    container.hidden = false
    const type = selected?.dataset.variableType || 'text'
    const options = JSON.parse(selected?.dataset.variableOptions || '[]')
    const label = selected?.dataset.variableLabel || ''
    const varName = container.dataset.variableName
    const currentValue = container.querySelector('[data-req-variable]')?.value || ''
    container.innerHTML = ''
    if (label) {
      const labelEl = document.createElement('label')
      labelEl.className = 'form-label mb-1'
      labelEl.textContent = label
      container.appendChild(labelEl)
    }
    if (type === 'select') {
      this.buildSelectInput(container, varName, options, currentValue, false)
    } else if (type === 'multi-select') {
      this.buildSelectInput(container, varName, options, currentValue.split(',').filter(Boolean), true)
    } else if (type === 'number') {
      const input = document.createElement('input')
      input.type = 'number'
      input.className = 'form-control'
      input.placeholder = 'Value'
      input.name = `${varName}[variable]`
      input.dataset.reqVariable = ''
      input.value = currentValue
      container.appendChild(input)
    } else {
      const input = document.createElement('input')
      input.type = 'text'
      input.className = 'form-control'
      input.placeholder = 'Value'
      input.name = `${varName}[variable]`
      input.dataset.reqVariable = ''
      input.value = currentValue
      container.appendChild(input)
    }
  },

  buildSelectInput(container, varName, options, currentValue, multiple) {
    if (multiple) {
      const hidden = document.createElement('input')
      hidden.type = 'hidden'
      hidden.name = `${varName}[variable]`
      hidden.dataset.reqVariable = ''
      hidden.value = Array.isArray(currentValue) ? currentValue.join(',') : currentValue

      const select = document.createElement('select')
      select.className = 'form-select select2'
      select.multiple = true
      select.dataset.reqMultiDisplay = ''
      options.forEach(([val, label]) => {
        const opt = new Option(label, val)
        opt.selected = currentValue.includes(val.toString())
        select.appendChild(opt)
      })
      const sync = () => {
        hidden.value = Array.from(select.selectedOptions)
          .map((o) => o.value)
          .join(',')
      }
      select.addEventListener('change', sync)
      if (window.$) $(select).on('select2:select select2:unselect', sync)
      container.appendChild(select)
      container.appendChild(hidden)
      if (window.App?.Form?.Select2Input) new window.App.Form.Select2Input(select, this.select2Options(container))
    } else {
      const select = document.createElement('select')
      select.className = 'form-select select2'
      select.name = `${varName}[variable]`
      select.dataset.reqVariable = ''
      select.appendChild(new Option('Select...', ''))
      options.forEach(([val, label]) => {
        const opt = new Option(label, val)
        opt.selected = val.toString() === currentValue.toString()
        select.appendChild(opt)
      })
      container.appendChild(select)
      if (window.App?.Form?.Select2Input) new window.App.Form.Select2Input(select, this.select2Options(container))
    }
  },
}
