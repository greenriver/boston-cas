###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM']
  layout 'mailer'

  if Rails.configuration.sandbox_email_mode
    ActionMailer::Base.register_interceptor SandboxEmailInterceptor
  end

  if ENV['SES_MONITOR_OUTGOING_EMAIL'] == 'true'
    ActionMailer::Base.register_interceptor CloudwatchEmailInterceptor
  end

  def notification_expired message
    @contact = message[:recipient]
    @body = message[:body]
    @subject = message[:subject]
    mail(to: @contact.email, subject: @subject, body: @body)
  end

  def self.prefix
    '[CAS]'
  end

  def prefix
    self.class.prefix
  end

  def self.remove_prefix(subject)
    if subject.starts_with? prefix
      subject[prefix.length..-1].strip
    else
      subject
    end
  end
end
