/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

export const RequirementVariableMixin = {
  wireMultiSelectSync(entry) {
    entry.querySelectorAll('[data-req-multi-display]').forEach((multiDisplay) => {
      const hidden = entry.querySelector('[data-req-variable]')
      if (!hidden) return
      const sync = () => {
        const selected = Array.from(multiDisplay.selectedOptions).map((o) => o.value)
        hidden.value = selected.join(',')
      }
      if (window.$) {
        $(multiDisplay).off('change.reqsync').on('change.reqsync', sync)
      } else {
        multiDisplay.addEventListener('change', sync)
      }
    })
  },

  select2Options(el) {
    const $modalContent = window.$ ? $(el).closest('.modal-content') : null
    const dropdownParent = $modalContent?.length ? $modalContent[0] : el.closest('form')
    return { dropdownParent, width: '100%' }
  },

  updateVariableInput(entry, ruleSelect) {
    const container = entry.querySelector('[data-req-variable-container]')
    if (!container) return

    const selectedOption = ruleSelect.options[ruleSelect.selectedIndex]
    const isVariable = selectedOption?.dataset?.variable === 'true'
    const varType = selectedOption?.dataset?.variableType || ''
    const varOptionsRaw = selectedOption?.dataset?.variableOptions || '[]'
    const varLabel = selectedOption?.dataset?.variableLabel || ''
    const varName = container.dataset.variableName

    container.hidden = !isVariable
    if (!isVariable) return

    const labelEl = container.querySelector('label')
    if (labelEl) labelEl.textContent = varLabel

    let varOptions = []
    try { varOptions = JSON.parse(varOptionsRaw) } catch (_e) {}

    container.innerHTML = ''
    if (labelEl) container.appendChild(labelEl)

    if (varType === 'select') {
      const sel = this._buildSelect(varName, varOptions)
      sel.setAttribute('data-req-variable', '')
      container.appendChild(sel)
      this._initSelect2(sel)
    } else if (varType === 'multi-select') {
      const multiSel = this._buildSelect(varName + '_display', varOptions, true)
      multiSel.setAttribute('data-req-multi-display', '')
      const hidden = document.createElement('input')
      hidden.type = 'hidden'
      hidden.name = varName + '[variable]'
      hidden.setAttribute('data-req-variable', '')
      container.appendChild(multiSel)
      container.appendChild(hidden)
      this._initSelect2(multiSel)
      this.wireMultiSelectSync(entry)
    } else if (varType === 'number') {
      const inp = document.createElement('input')
      inp.type = 'number'
      inp.className = 'form-control'
      inp.name = varName + '[variable]'
      inp.placeholder = 'Value'
      inp.setAttribute('data-req-variable', '')
      container.appendChild(inp)
    } else {
      const inp = document.createElement('input')
      inp.type = 'text'
      inp.className = 'form-control'
      inp.name = varName + '[variable]'
      inp.placeholder = 'Value'
      inp.setAttribute('data-req-variable', '')
      container.appendChild(inp)
    }
  },

  _buildSelect(name, options, multiple = false) {
    const sel = document.createElement('select')
    sel.className = 'form-select select2'
    sel.name = name
    if (multiple) sel.multiple = true
    if (!multiple) {
      const blank = document.createElement('option')
      blank.value = ''
      blank.textContent = 'Select...'
      sel.appendChild(blank)
    }
    options.forEach(([val, label]) => {
      const opt = document.createElement('option')
      opt.value = val
      opt.textContent = label
      sel.appendChild(opt)
    })
    return sel
  },

  _initSelect2(el) {
    if (window.App?.Form?.Select2Input) {
      new window.App.Form.Select2Input(el, this.select2Options(el))
    }
  },
}
