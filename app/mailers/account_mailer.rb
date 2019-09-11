###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class AccountMailer < Devise::Mailer
  default template_path: 'devise/mailer'

  if ENV['SES_MONITOR_OUTGOING_EMAIL'] == 'true'
    ActionMailer::Base.register_interceptor CloudwatchEmailInterceptor
  end

  def invitation_instructions(record, action, opts = {})
    opts[:subject] = _('CAS') + ": Account Activation Instructions"
    super
  end
end
