class ApplicationMailer < ActionMailer::Base
  default from: '"Boston Coordinated Access" <help@cas.boston.gov>'
  layout 'mailer'

  if Rails.configuration.sandbox_email_mode
    ActionMailer::Base.register_interceptor SandboxEmailInterceptor
  end
end
