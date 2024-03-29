###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module NotifierConfig
  extend ActiveSupport::Concern
  included do
    attr_accessor :notifier_config

    def setup_notifier(username)
      @notifier_config = Rails.application.config_for(:exception_notifier).fetch(:slack, nil)
      @send_notifications = notifier_config.present? && notifier_config['webhook_url'].present? && ( Rails.env.development? || Rails.env.production? )
      if @send_notifications
        slack_url = notifier_config['webhook_url']
        channel   = notifier_config['channel']
        @notifier  = Slack::Notifier.new slack_url, channel: channel, username: username
      end
    end
  end
end
