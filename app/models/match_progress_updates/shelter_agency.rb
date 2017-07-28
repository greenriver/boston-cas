module MatchProgressUpdates
  class ShelterAgency < Base
    
    def name
      'Shelter Agency status update'
    end

    def self.match_contact_scope
      :shelter_agency_contacts
    end

  end
end
