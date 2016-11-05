class ApplicationMailer < ActionMailer::Base
  default from: '"Boston Coordinated Access" <cas-help@boston.gov>'
  layout 'mailer'

  if Rails.configuration.sandbox_email_mode
    ActionMailer::Base.register_interceptor SandboxEmailInterceptor
  end

  def notification_expired message
    @contact = message[:recipient]
    @body = message[:body]
    @subject = message[:subject]
    mail(to: @contact.email, subject: @subject, body: @body)
  end
end
