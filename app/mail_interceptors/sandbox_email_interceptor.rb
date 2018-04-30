class SandboxEmailInterceptor
  # TODO: list recipients who will always be BCC'd when application is running in sandbox mode
  RECIPIENTS = ENV['SANDBOX_RECIPIENTS']&.split(';') || []
  
  # TODO: list whitelisted email addresses here -- any other emails will only be BCC'd to the above
  # when this intercepter is in place
  ENV_WHITELIST = ENV['SANDBOX_WHITELIST']&.split(';') || []
  WHITELIST = (ENV_WHITELIST + RECIPIENTS).compact.map!(&:downcase)

  def self.delivering_email mail
    # mail.to = mail.to.to_a.select{|a| WHITELIST.include? a.downcase}
    # mail.cc = mail.cc.to_a.select{|a| WHITELIST.include? a.downcase}
    mail.bcc = RECIPIENTS
    unless Rails.env.production? || mail.delivery_method.is_a?(ApplicationMailer.delivery_methods[:db])
      mail.subject = "[TRAINING] #{mail.subject}"
      mail.body = warning + String(mail.body)
    end
  end

  def self.warning
    "***This message is for training purposes only, the following information is fictitious and does not represent a real housing opportunity or homeless client.***\n\n"
  end

end
