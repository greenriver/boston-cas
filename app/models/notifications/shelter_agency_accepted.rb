###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications
  class ShelterAgencyAccepted < Base
    def self.contact_types_for_notification
      [
        :shelter_agency_contacts,
        :dnd_staff_contacts,
      ]
    end

    def decision
      match.match_recommendation_shelter_agency_decision
    end

    def event_label
      "#{Translation.translate('Shelter Agency')} and #{Translation.translate('DND')} were notified of #{Translation.translate('Shelter Agency')} match acceptance"
    end
  end
end
