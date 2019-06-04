###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchProgressUpdates
  class ShelterAgency < Base
    
    def name
      "#{_('Shelter Agency')} status update"
    end

    def self.match_contact_scope
      :shelter_agency_contacts
    end

  end
end
