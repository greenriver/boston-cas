###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# bundle exec rails runner 'TestMailer.ping(email: "somebody@greenriver.com").deliver_now'
class TestMailer < ApplicationMailer
  default from: ENV.fetch('DEFAULT_FROM')
  def ping(email)
    mail({
      to: [email],
      subject: 'test'
    }) do |format|
      format.text { render plain: "Test #{SecureRandom.hex(6)}" }
    end
  end
end
