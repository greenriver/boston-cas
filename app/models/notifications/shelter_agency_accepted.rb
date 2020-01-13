###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications
  class ShelterAgencyAccepted < Base

    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.match_recommendation_shelter_agency_decision
    end

    def event_label
      "#{_('Shelter Agency')} and #{_('DND')} were notified of #{_('Shelter Agency')} match acceptance"
    end

  end
end
