###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchProgressUpdates
  class ShelterAgency < Base

    def name
      "#{Translation.translate('Shelter Agency')} status update"
    end

    def self.match_contact_scope
      :shelter_agency_contacts
    end

  end
end
