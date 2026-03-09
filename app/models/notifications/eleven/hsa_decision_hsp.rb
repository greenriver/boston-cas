###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Eleven
  class HsaDecisionHsp < ::Notifications::Base
    # Notification sent to a client of a decision made by the housing subsidy administrator

    def self.contact_types_for_notification
      [:hsp_contacts]
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "eleven_#{self.class.to_s.demodulize.underscore}"
    end

    def event_label
      "#{Translation.translate('Housing Search Provider Eleven')} sent notice of #{Translation.translate('Housing Subsidy Administrator Eleven')}'s decision."
    end
  end
end
