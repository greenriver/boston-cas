###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class AccountMailer < Devise::Mailer
  default template_path: 'devise/mailer'

  ActionMailer::Base.register_interceptor CloudwatchEmailInterceptor if ENV['SES_MONITOR_OUTGOING_EMAIL'] == 'true'

  def invitation_instructions(record, action, opts = {})
    opts[:subject] = _('Boston Coordinated Access') + ': Account Activation Instructions'
    super
  end
end
