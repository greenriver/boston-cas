$ ->

  # The drawer menu (see objects/_menu.scss) is fixed-position and needs to
  # start below the header, but the non-production/impersonation banners
  # above the header (layouts/_header_warnings.haml) vary in height, and
  # neither the banners nor the header are fixed/sticky — they scroll away
  # with the page. So the offset isn't a constant: it's the banner+header
  # height at rest, shrinking to 0 as the page scrolls past where they were,
  # otherwise the drawer would leave a gap where they used to be.
  restingMenuOffsetTop = 0

  measureRestingMenuOffsetTop = ->
    header = document.querySelector('.o-header--page')
    return unless header
    restingMenuOffsetTop = header.getBoundingClientRect().bottom + window.scrollY

  applyMenuOffsetTop = ->
    offset = Math.max(0, restingMenuOffsetTop - window.scrollY)
    document.documentElement.style.setProperty('--nav-side-offset-top', "#{offset}px")

  measureRestingMenuOffsetTop()
  applyMenuOffsetTop()
  $(window).on 'resize', ->
    measureRestingMenuOffsetTop()
    applyMenuOffsetTop()

  # Toggle menu (move on/off canvas) on small screens
  $('.js-toggle-menu').on 'click', (event) ->
    event.preventDefault()
    $('body').toggleClass('menu-open')
    $('.js-menu').toggleClass('off-canvas on-canvas')

  $('.js-back-to-top').on 'click', (event) ->
    event.preventDefault()
    $('body,html').animate { scrollTop: 0 }, 500

  lastPoint = 0
  scrollTicking = false
  $(window).scroll ->
    return if scrollTicking
    scrollTicking = true
    window.requestAnimationFrame ->
      scrollTicking = false

      applyMenuOffsetTop()

      action  = 'removeClass'
      scrollY = window.scrollY
      if scrollY > window.innerHeight && lastPoint > scrollY
        action  = 'addClass'

      $('.js-back-to-top')[action]('active')
      lastPoint = scrollY
