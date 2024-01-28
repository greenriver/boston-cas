###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Five
  class LeaseUp < Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.five_lease_up_decision
    end

    def event_label
      "Awaiting #{match_route.contact_label_for(:shelter_agency_contacts)} Lease Up"
    end
  end
end
