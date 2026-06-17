###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Mail
  class SesDelivery
    def initialize(parameters)
      @parameters = parameters
    end

    def deliver!(mail)
      client = Aws::SES::Client.new
      client.send_raw_email(raw_message: { data: mail.to_s })
    end
  end
end
