###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

# bundle exec rails runner 'TestMailer.with(email: "somebody@greenriver.com").ping.deliver_now'
class TestMailer < ApplicationMailer
  default from: ENV.fetch('DEFAULT_FROM')
  def ping(email)
    email = params[:email[]]
    mail({
      to: [email],
      subject: 'test'
    }) do |format|
      format.text { render plain: "Test #{SecureRandom.hex(6)}" }
    end
  end
end
