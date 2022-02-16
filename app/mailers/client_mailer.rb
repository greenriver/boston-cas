###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClientMailer < ApplicationMailer
  def new_match(recipient)
    mail(to: recipient, subject: "Housing Opportunity")
  end
end
