module Notifications
  class HousingSubsidyAdminDecisionShelterAgency < Base
    # Notification sent to a client of a decision made by the housing subsidy administrator
    
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Shelter Agency')} sent notice of #{_('Housing Subsidy Administrator')}'s decision."
    end

  end
end
