###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Seven
  class MatchInProgressShelterAgency < ::Notifications::Base
    def self.contact_types_for_notification
      [:shelter_agency_contacts]
    end

    def decision
      match.seven_approve_match_housing_subsidy_admin_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} notified of approved potential match."
    end
  end
end
