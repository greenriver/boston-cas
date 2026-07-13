#############
# Ajax modals
#############
class window.AjaxModal
  constructor: ->
    @modal = $(".modal[data-ajax-modal]")
    @linkTriggersSelector = '[data-loads-in-ajax-modal], [data-loads-in-pjax-modal]'
    @formTriggersSelector = '[data-submits-to-ajax-modal], [data-submits-to-pjax-modal]'
    @closeSelector = '[data-ajax-modal-close], [data-pjax-modal-close], [pjax-modal-close]'
    @initialPath = window.location.toString()
    @loading = @modal.find("[data-ajax-modal-loading]")
    @title = @modal.find("[data-ajax-modal-title]")
    @content = @modal.find("[data-ajax-modal-content]")
    @footer = @modal.find("[data-ajax-modal-footer]")

    @listen()

  listen: ->
    @_registerLinks()
    @_registerForms()
    @_registerClose()
    @_registerOnHide()

  _initSelect2WhenReady: (contentReady, modalShown, content) ->
    # Bootstrap 5 modal animations run ~300ms. If the AJAX response arrives before
    # the animation completes, select2 cannot measure the container width and renders
    # at the wrong size. Both flags must be true before we initialize.
    if contentReady[0] and modalShown[0]
      content.find('select.select2').select2({ dropdownParent: content.closest('.modal-content') })

  _registerLinks: ->
    $('body').on 'click', @linkTriggersSelector, (e) =>
      e.preventDefault()
      @open()
      history.replaceState({}, 'Modal', $(e.target).attr("href"))
      contentReady = [false]
      modalShown = [false]
      content = @content
      @modal.one 'shown.bs.modal', =>
        modalShown[0] = true
        @_initSelect2WhenReady(contentReady, modalShown, content)
      $.ajax
        url: e.currentTarget.getAttribute("href"),
        dataType: 'html',
        headers: {
          'X-AJAX-MODAL': true
        },
        complete: (xhr, status) =>
          @loading.hide()
          @content.html xhr.responseText
          contentReady[0] = true
          @_initSelect2WhenReady(contentReady, modalShown, content)
          @open

  _registerForms: ->
    # scope.find(@formTriggersSelector).attr('data-remote', true)
    $('body').on 'submit', @formTriggersSelector, (event) =>
      form = event.currentTarget
      event.preventDefault()
      @open()
      contentReady = [false]
      modalShown = [false]
      content = @content
      @modal.one 'shown.bs.modal', =>
        modalShown[0] = true
        @_initSelect2WhenReady(contentReady, modalShown, content)
      $.ajax
        url: form.getAttribute('action')
        type: form.getAttribute('method')
        dataType: 'html',
        data: $(form).serialize(),
        headers: {
          'X-AJAX-MODAL': true
        },
        complete: (xhr, status) =>
          @loading.hide()
          @content.html xhr.responseText
          contentReady[0] = true
          @_initSelect2WhenReady(contentReady, modalShown, content)
          @open
      return false

  # maybe don't need this for bootstrap
  _registerClose: ->
    @modal.on 'click', @closeSelector, =>
      @closeModal()

  _registerOnHide: ->
    @modal.on "hidden.bs.modal", =>
      @reset()
      history.replaceState({}, 'Modal', @initialPath);

  open: ->
    @modal.modal 'show'

  close: ->
    @reset()
    @modal.modal('hide')

  closeModal: ->
    @close()

  reset: ->
    $("[data-ajax-modal-title]").html("Loading")
    $("[data-ajax-modal-body]").html("")
    $("[data-ajax-modal-footer]").html("")
    $("[data-ajax-modal-loading]").show()

  closeAndReload: ->
    @close
    if @initialPath
      history.pushState({}, 'Modal', @initialPath);
    window.location.reload()
