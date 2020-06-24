###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::HomelessSetAside
  class MatchInitiationForShelterAgency < ::Notifications::Base

    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Shelter Agency')} notified of match detail"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      false
    end

  end
end
