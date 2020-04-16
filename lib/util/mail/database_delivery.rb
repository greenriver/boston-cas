# munged out of https://gist.github.com/d11wtq/1176236
module Mail
  class DatabaseDelivery

    def initialize(parameters)
      @parameters = {}.merge(parameters)
    end

    def deliver!(mail)
      is_html, body = content_and_type mail
      subject       = ApplicationMailer.remove_prefix mail.subject
      from          = mail[:from].addresses.first || ENV['DEFAULT_FROM']

      if from.nil?
        Rails.logger.fatal "no DEFAULT_FROM specified in .env; mail cannot be sent"
      end
      Contact.where( email: mail[:to].addresses ).each do |contact|
        # store the "email" in the database
        message = ::Message.create(
          contact_id: contact.id,
          subject: subject,
          body:    body,
          from:    from,
          html:    is_html,
        )
        user = contact.user
        if user.blank? || user.continuous_email_delivery?
          ::ImmediateMailer.with(message: message, to: contact.email).immediate.deliver_now
          message.update(sent_at: Time.current, seen_at: Time.current)
        end
      end
    end

    # save content as HTML if possible
    def content_and_type(mail)
      if mail.body.parts.any?
        html_part = mail.body.parts.find{ |p| p.content_type.starts_with? "text/html" }
        return [ true, html_part.body.to_s ] if html_part
        text_part = mail.body.parts.find{ |p| p.content_type.starts_with? "text/plain" }
        return [ false, text_part.body.to_s ] if text_part
      end
      body    = mail.body.to_s
      is_html = /\A<html>.*<\/html>\z/im === body.strip
      [ is_html, body ]
    end
  end
end