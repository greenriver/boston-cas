###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenHearingOutcomeShelterAgency < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.thirteen_hearing_outcome_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency Thirteen')} notified of scheduled hearing."
    end
  end
end
