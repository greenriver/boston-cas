###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class DigestMailer < ApplicationMailer
  def digest(user, messages)
    @messages = messages
    # quietly eat messages if the user is no longer active
    unless user.active?
      Rails.logger.info("#{user.name} #{user.email} no longer active, refusing to send a message")
      return
    end

    mail to: user.email, subject: "#{prefix} #{user.email_schedule} digest"
  end
end
