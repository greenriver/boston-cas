###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Seven
  class MatchSuccessShelterAgency < ::Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.seven_confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{_('Shelter Agency')} notified of successful match."
    end
  end
end
