###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenHearingScheduledShelterAgency < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.thirteen_hearing_scheduled_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency Thirteen')} notified of pending CORI review."
    end
  end
end
