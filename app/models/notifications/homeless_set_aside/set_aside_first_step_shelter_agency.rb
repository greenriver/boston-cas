###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::HomelessSetAside
  class SetAsideFirstStepShelterAgency < ::Notifications::Base
    def self.create_for_match! match
      match.shelter_agency_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{Translation.translate('Shelter Agency Contact')} notified of match detail"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      false
    end
  end
end
