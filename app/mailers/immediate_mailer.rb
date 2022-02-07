###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ImmediateMailer < ApplicationMailer
  def immediate
    to = params[:to]
    @message = params[:message]

    # Don't send to disabled accounts, but let contacts with no accounts go through
    inactive_user = User.inactive.find_by(email: to)
    return if inactive_user.present?

    mail to: to, subject: "#{prefix} #{@message.subject}"
  end
end
