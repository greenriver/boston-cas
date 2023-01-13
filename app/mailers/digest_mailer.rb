###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
