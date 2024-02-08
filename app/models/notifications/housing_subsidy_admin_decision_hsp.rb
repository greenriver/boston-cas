###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class HousingSubsidyAdminDecisionHsp < Base
    # Notification sent to a client of a decision made by the housing subsidy administrator

    def self.create_for_match! match
      match.hsp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{Translation.translate('Housing Search Provider')} sent notice of #{Translation.translate('Housing Subsidy Administrator')}'s decision."
    end

  end
end
