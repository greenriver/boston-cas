###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClientMailer < ApplicationMailer
  def new_match(match)
    @match = match
    @client = match.client
    mail(to: @client.email, subject: 'Housing Opportunity')
  end
end
