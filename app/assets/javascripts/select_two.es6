//= require namespace
//= require select2

App.Form = App.Form || {}

App.Form.Select2Input = class Select2Input {
  constructor(elementId) {
    const field = document.getElementById(elementId)
    if (!field) {
      console.debug(`Select2Input could not find id: ${elementId}`)
    } else {
      this.$select = $(field)
      console.log(this.$select.find('option:first').attr('selected', true))
      this.$select2Container = this.$select.next('.select2-container')
      this.$select.select2()
      // Add ability to select all/none if the select2 is multiselect
      if (field.hasAttribute('multiple')) {
        this.initToggleSelectAll()
      }
    }
  }

  selectAllHtml() {
    let text = 'all'
    if (this.someItemsSelected() || this.allItemsSelected()) {
      text = 'none'
    }
    return `<span class='mr-2'>Select ${text}</span>`
  }

  numberOfSelectedItems() {
    return this.$select.find('option:selected').length
  }

  someItemsSelected() {
    return this.numberOfSelectedItems() && !this.allItemsSelected()
  }

  allItemsSelected() {
    return this.numberOfSelectedItems() === this.$select.find('option').length
  }

  toggleSelectAll(isManualChange=false) {
    if (!isManualChange) {
      this.$select.find('option').prop("selected", !this.allItemsAreSelected)
      this.allItemsAreSelected = !this.allItemsAreSelected
    } else {
      if (this.someItemsSelected() || this.allItemsSelected()) {
        this.allItemsAreSelected = true
      } else {
        this.allItemsAreSelected = false
      }
    }
    this.$select.trigger('change')
    this.$select.select2('close')

    // Update DOM element to reflect selections
    const $selectAllLink = this.$formGroup.find('.select2-select-all')
    let classAction = 'removeClass'
    // this.$select2Container[classAction]('all-selected')
    let html = this.selectAllHtml()
    if (this.allItemsSelected() || this.numberOfSelectedItems()) {
      classAction = 'addClass'
      html = this.selectAllHtml()
    }
    $selectAllLink.html(html)
  }


  noneSelected() {
    return (this.$formGroup.find('select').val() === 0) ||
      (this.$select.select2('data').length === 0)
  }

  initToggleSelectAll() {
    // Init here
    const hasItemsSelectedOnInit = this.numberOfSelectedItems()
    this.$formGroup = this.$select.closest('.form-group')
    this.$formGroup.addClass('select2-wrapper')
    const $label = this.$formGroup.find('> label')
    const $labelWrapper = $("<div class='select2__label-wrapper'></div>")
    // Add select all/none link to select2 input
    $labelWrapper.append($(`
      <div class="select2-select-all j-select2-select-all">
        ${this.selectAllHtml()}
      </div>
    `))
    $label.prependTo($labelWrapper)
    this.$formGroup.prepend($labelWrapper)

    // Init events on select2
    // Trigger toggle on manual update: 'select2:select select2:unselect
    // Trigger toggle on select all/ none click: '.j-select2-select-all'
    this.$select.closest('.form-group')
      .on( 'click', '.j-select2-select-all', this.toggleSelectAll.bind(this, false) )
    this.$select.on( 'select2:select select2:unselect', this.toggleSelectAll.bind(this, true) )

    // Initial state based on existing options
    this.allItemsAreSelected = this.numberOfSelectedItems()
  }
}
