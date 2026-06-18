###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
