/*
 * Copyright 2016 - 2025 Green River Data Analysis, LLC
 *
 * License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
 */

(function () {
  if (typeof window.Stimulus === 'undefined') return
  if (typeof window.StimulusHistoryController === 'undefined') return

  const { Application } = window.Stimulus
  const application = Application.start()
  application.register('history', window.StimulusHistoryController)
})()
