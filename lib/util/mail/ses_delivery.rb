###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
