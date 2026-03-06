###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Seven
  class MatchSuccessShelterAgency < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.seven_confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} notified of successful match."
    end
  end
end
