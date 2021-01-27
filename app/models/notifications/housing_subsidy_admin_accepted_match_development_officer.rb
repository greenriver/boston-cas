###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class HousingSubsidyAdminAcceptedMatchDevelopmentOfficer < Base
    # Notification sent to DO of an approval decision made by the housing subsidy administrator

    # rejections are handled in a separate notification with a link to the opportunity to override.

    def self.create_for_match! match
      match.do_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "Sent notice of #{_('Housing Subsidy Administrator')}'s decision to #{_('Development Officer')}"
    end

  end
end
