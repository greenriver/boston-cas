###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
