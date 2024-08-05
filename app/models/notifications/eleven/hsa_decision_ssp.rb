###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eleven
  class HsaDecisionSsp < ::Notifications::Base
    # Notification sent to a client of a decision made by the housing subsidy administrator

    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "eleven_#{self.class.to_s.demodulize.underscore}"
    end

    def event_label
      "#{Translation.translate('Stabilization Services Provider Eleven')} sent notice of #{Translation.translate('Housing Subsidy Administrator Eleven')}'s decision."
    end
  end
end
