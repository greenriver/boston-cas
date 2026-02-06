###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class Mitigation < Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def self.create_for_match! match
      contact_types_for_notification.each do |contact_type|
        match.send(contact_type).each do |contact|
          create! match: match, recipient: contact
        end
      end
    end

    def decision
      match.five_mitigation_decision
    end

    def event_label
      "#{match_route.contact_label_for(:shelter_agency_contacts)} performing mitigation"
    end
  end
end
