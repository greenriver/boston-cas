###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Five
  class Mitigation < Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.five_mitigation_decision
    end

    def event_label
      "#{match.match_route.contact_label_for(:shelter_agency_contacts)} performing mitigation"
    end
  end
end
