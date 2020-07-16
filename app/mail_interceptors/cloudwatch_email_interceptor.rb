###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class CloudwatchEmailInterceptor
  def self.delivering_email message
    message.headers({
      'X-SES-CLIENT' => ENV.fetch('CLIENT') { 'UnknownClient' },
      'X-SES-APP' => 'CAS',
      'X-SES-CONFIGURATION-SET' => ENV.fetch('SES_CONFIG_SET') { 'OpenPathConfigSet' },
      'X-SES-ENVIRONMENT' => Rails.env
    })
  end
end
