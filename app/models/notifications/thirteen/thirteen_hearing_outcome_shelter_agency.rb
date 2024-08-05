###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Thirteen
  class ThirteenHearingOutcomeShelterAgency < ::Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.thirteen_hearing_outcome_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency Thirteen')} notified of scheduled hearing."
    end

    def to_partial_path
      "notifications/thirteen/#{notification_type}"
    end
  end
end
