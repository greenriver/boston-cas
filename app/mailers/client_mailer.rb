###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ClientMailer < ApplicationMailer
  def new_match(match)
    @match = match
    @client = match.client
    mail(to: @client.email, subject: 'Housing Opportunity')
  end
end
