###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ImmediateMailer < ApplicationMailer
  def immediate(message, recipient, delivery_method_options = nil)
    @message = message
    # Don't send to disabled accounts, but let contacts with no accounts go through
    inactive_user = User.inactive.find_by(email: recipient)
    return if inactive_user.present?

    mail(
      from: message.from,
      to: recipient,
      subject: "#{prefix} #{@message.subject}",
      delivery_method_options: delivery_method_options,
    )
  end
end
