###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenMatchAcknowledgementShelterAgency < ::Notifications::Base
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
      match.thirteen_match_acknowledgement_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency Thirteen')} notified of match."
    end
  end
end
