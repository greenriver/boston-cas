###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications
  class ConfirmShelterAgencyDeclineDndStaff < Base
    
    def self.create_for_match! match
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def decision
      match.confirm_shelter_agency_decline_dnd_staff_decision
    end

    def event_label
      "#{_('DND')} notified of #{_('Shelter Agency')} decline.  Confirmation pending."
    end

  end
end
