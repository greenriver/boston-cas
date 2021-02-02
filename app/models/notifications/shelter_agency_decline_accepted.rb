###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
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
      "#{_('Shelter Agency')} notified of #{_('DND')} acceptance of #{_('Shelter Agency')} decline"
    end

  end
end
