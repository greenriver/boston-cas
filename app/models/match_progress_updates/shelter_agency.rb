module MatchProgressUpdates
  class ShelterAgency < Base
    
    def name
      'ShelterAgency status update'
    end

    def responses
      [
        'Response 1',
        'Response 2',
      ]
    end

    def self.match_contact_scope
      :shelter_agency_contacts
    end

  end
end