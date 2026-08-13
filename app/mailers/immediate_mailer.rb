###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class ImmediateMailer < ApplicationMailer
  def immediate(message, recipient, delivery_method_options = nil)
    @message = message
    # Don't send to disabled accounts, or contacts with no accounts
    contact = Contact.find_by(email: recipient)
    return if contact.blank? || !contact.notification_recipient?

    mail(
      from: message.from,
      to: recipient,
      subject: "#{prefix} #{@message.subject}",
      delivery_method_options: delivery_method_options,
    )
  end
end
