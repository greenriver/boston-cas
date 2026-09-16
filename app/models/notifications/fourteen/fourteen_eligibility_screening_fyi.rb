###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Fourteen
  class FourteenEligibilityScreeningFyi < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :ssp_contacts, :dnd_staff_contacts]
    end

    def decision
      match.fourteen_eligibility_screening_decision
    end

    def event_label
      'Match contacts notified that eligibility screening is underway.'
    end
  end
end
