###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# bundle exec rails runner 'TestDatabaseMailer.ping(email: "somebody@greenriver.com").deliver_now'

class TestDatabaseMailer < DatabaseMailer
  default from: 'noreply@greenriver.com'

  def ping(email)
    mail(
      to: [email],
      subject: 'test',
    ) do |format|
      format.text { render plain: "Test #{SecureRandom.hex(6)}" }
    end
  end
end
