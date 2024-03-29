###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications
  class ShelterAgencyDeclineAccepted < Base

    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.confirm_shelter_agency_decline_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} notified of #{Translation.translate('DND')} acceptance of #{Translation.translate('Shelter Agency')} decline"
    end

  end
end
